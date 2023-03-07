#!/bin/sh

# [set -e, -u, -o, -x pipefail explanation](https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3945021)
# -e: exit on error
set -eufo pipefail

#- ask for admin password upfront
sudo -v
# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


# Install Xcode Command Line Tools 
#xcode-select --install
xcode_path=$(xcode-select -p)
if [ "$xcode_path" != "/Library/Developer/CommandLineTools" ]; then
  echo "Installation of Xcode Command Line Tools failed"
  exit 1
fi

# Test xcode installation
#echo "Enter superuser (sudo) password to accept Xcode license"
#sudo xcodebuild -license accept
#sudo xcodebuild -runFirstLaunch


# install Homebrew with applications
source ./scripts/setup_homebrew_macos.zsh


exit 0

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
# exec: replace current process with chezmoi init
exec "$chezmoi" init --apply "--source=$script_dir"
