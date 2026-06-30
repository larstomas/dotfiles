#!/bin/sh

set -e # -e: exit on error

if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "$bin_dir"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://get.chezmoi.io)" -- -b "$bin_dir"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
else
  chezmoi=chezmoi
fi

#- Log the whole bootstrap to a timestamped file (XDG state dir)
log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/chezmoi"
mkdir -p "$log_dir"
log_file="$log_dir/install-$(date +%Y%m%d-%H%M%S).log"
echo "Logging installation to $log_file"

#- Init and apply with chezmoi, teeing all output to the log.
# Same command as: chezmoi init --apply https://github.com/larstomas/dotfiles.git
# tee loses the pipeline's exit status in POSIX sh, so capture it via a temp file.
status_file="$(mktemp)"
{ "$chezmoi" init --apply larstomas 2>&1; echo "$?" >"$status_file"; } | tee "$log_file"
status="$(cat "$status_file")"
rm -f "$status_file"

echo "chezmoi finished with exit status $status (log: $log_file)"
exit "$status"
