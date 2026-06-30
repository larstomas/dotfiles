#!/bin/sh

set -e # -e: exit on error

# Bootstrap with chezmoi. If chezmoi is not installed, download it (a throwaway
# copy under ./bin). Homebrew installs the permanent chezmoi during apply, and the
# zzz-cleanup-bootstrap-chezmoi script removes the throwaway afterwards.

#- Log the whole bootstrap to a timestamped file (XDG state dir)
log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/chezmoi"
mkdir -p "$log_dir"
log_file="$log_dir/install-$(date +%Y%m%d-%H%M%S).log"
echo "Logging installation to $log_file"

# tee loses the pipeline's exit status in POSIX sh, so capture it via a temp file.
status_file="$(mktemp)"

# On macOS, chezmoi needs git to clone the dotfiles, and git ships with the Xcode
# Command Line Tools. Install them BEFORE `chezmoi init`, otherwise the clone fails.
# This must happen here (not in a chezmoi script) because those scripts live inside
# the repo we cannot clone yet. No-op if the tools are present or on non-macOS.
ensure_xcode_clt() {
  [ "$(uname -s)" = "Darwin" ] || return 0
  xcode-select -p >/dev/null 2>&1 && return 0
  echo ">>> Installing Xcode Command Line Tools (git is required to clone the dotfiles)..."
  xcode-select --install >/dev/null 2>&1 || true
  echo ">>> Click \"Install\" in the dialog; waiting for the tools to finish..."
  i=0
  while ! xcode-select -p >/dev/null 2>&1; do
    i=$((i + 1))
    [ "$i" -ge 240 ] && { echo "Timed out waiting for Xcode Command Line Tools." >&2; return 1; }
    sleep 5
  done
  echo ">>> Xcode Command Line Tools installed."
}

# Ensure git exists before `chezmoi init` clones the repo. On macOS git ships with
# the Command Line Tools; on Linux install it with the available package manager
# (the linux install-packages script installs git too, but that runs post-clone).
ensure_git() {
  if [ "$(uname -s)" = "Darwin" ]; then
    ensure_xcode_clt
    return
  fi
  command -v git >/dev/null 2>&1 && return 0
  echo ">>> Installing git (required to clone the dotfiles)..."
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -y && sudo apt-get install -y git
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y git
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm git
  elif command -v zypper >/dev/null 2>&1; then
    sudo zypper install -y git
  else
    echo "No supported package manager found to install git; install it and re-run." >&2
    return 1
  fi
}

run() {
  ensure_git
  # Same as the README one-liner, with output teed to the log.
  if command -v chezmoi >/dev/null 2>&1; then
    chezmoi init --apply larstomas
  elif command -v curl >/dev/null 2>&1; then
    sh -c "$(curl -fsSL https://get.chezmoi.io)" -- init --apply larstomas
  elif command -v wget >/dev/null 2>&1; then
    sh -c "$(wget -qO- https://get.chezmoi.io)" -- init --apply larstomas
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    return 1
  fi
}

{ run 2>&1; echo "$?" >"$status_file"; } | tee "$log_file"
status="$(cat "$status_file")"
rm -f "$status_file"

echo "chezmoi finished with exit status $status (log: $log_file)"
exit "$status"
