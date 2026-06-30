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

run() {
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
