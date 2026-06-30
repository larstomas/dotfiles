#!/bin/bash

#- Error handling
# [set -e, -u, -o, -x pipefail explanation](https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3945021)
# -e: exit on error
set -euf -o pipefail

#- Logging: tee all output to a shared log (also stays on the terminal)
chezmoi_log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/chezmoi"
mkdir -p "$chezmoi_log_dir"
exec > >(tee -a "$chezmoi_log_dir/install.log") 2>&1
printf '\n===== %s  %s =====\n' "$(date '+%F %T')" "$(basename -- "$0")"

echo "Running script has basename $( basename -- "$0"; ), dirname $( dirname -- "$0"; )";
echo "The present working directory is $( pwd; )";

#- Ask for admin password upfront
sudo -v
# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

#- Install Xcode Command Line Tools
if [ "$(xcode-select -p)" != "/Library/Developer/CommandLineTools" ] && [ "$(xcode-select -p)" != "/Applications/Xcode.app/Contents/Developer" ]; then
  xcode-select --install
  echo ">>> Wait for Xcode Command Line Tools to install"
  read -r -p "Press any key to continue "
fi

#-- Test xcode installation
if [ "$(xcode-select -p)" != "/Library/Developer/CommandLineTools" ] && [ "$(xcode-select -p)" != "/Applications/Xcode.app/Contents/Developer" ]; then
  echo "Installation of Xcode Command Line Tools failed, Xcode path not right"
  exit 1
fi
echo "Xcode Command Line Tools is installed"

