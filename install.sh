#!/bin/sh

#- Error handling 
# [set -e, -u, -o, -x pipefail explanation](https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3945021)
# -e: exit on error
set -eufo pipefail

#- Ask for admin password upfront
sudo -v
# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


#- Functions
function command_exists() {
  # `command -v` is similar to `which`
  # https://stackoverflow.com/a/677212/1341838
  command -v $1 >/dev/null 2>&1
}


#- Install Xcode Command Line Tools 
if !(command_exists xcode-select); then
  time xcode-select --install
  echo ">>> Wait for Xcode Command Line Tools to install"
  read -p "Press any key to continue "
fi

#-- Test xcode installation
if command_exists xcode-select; then
  if [ "$(xcode-select -p)" != "/Library/Developer/CommandLineTools" ]; then
    echo "Installation of Xcode Command Line Tools failed, Xcode path not right"
    exit 1
  fi
else
  echo "Installation of Xcode Command Line Tools failed, xcode-select command not found"
  exit 1
fi
echo "Xcode Command Line Tools is installed"


#- Install Homebrew with applications
source ./scripts/setup_homebrew_macos.zsh

exit 0

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
# exec: replace current process with chezmoi init
exec "$chezmoi" init --apply "--source=$script_dir"
