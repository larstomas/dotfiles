#!/bin/sh

#- Error handling 
# [set -e, -u, -o, -x pipefail explanation](https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3945021)
# -e: exit on error
set -euf -o pipefail

echo "Running script has basename $( basename -- "$0"; ), dirname $( dirname -- "$0"; )";
echo "The present working directory is $( pwd; )";

#- Ask for admin password upfront
sudo -v
# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


#- Install Xcode Command Line Tools 
if [ "$(xcode-select -p)" != "/Library/Developer/CommandLineTools" ]; then
  xcode-select --install
  echo ">>> Wait for Xcode Command Line Tools to install"
  read -p "Press any key to continue "
fi

#-- Test xcode installation
if [ "$(xcode-select -p)" != "/Library/Developer/CommandLineTools" ]; then
  echo "Installation of Xcode Command Line Tools failed, Xcode path not right"
  exit 1
fi
echo "Xcode Command Line Tools is installed"


#- Install Homebrew with applications
#source ./scripts/setup_homebrew_macos.zsh
brew bundle --no-lock --file=/dev/stdin <<EOF
tap "1password/tap"
tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/cask-fonts"
tap "homebrew/core"
brew "chezmoi"
brew "exa"
brew "spaceship"
brew "zsh"
cask "1password"
cask "1password-cli"
cask "appcleaner"
mas "1Password for Safari", id: 1569813296
mas "Accelerate", id: 1459809092
mas "Amphetamine", id: 937984704
EOF

#- Configure 1Password
open -a 1Password
echo ">>> Configure 1Password - https://developer.1password.com/docs/cli/get-started/"
read -p "Then press any key to continue"


#- Sign in to 1Password, need 1Password-CLI to be installed
SUBDOMAIN="backman"
EMAIL="larstomas@gmail.com"
op account add --address $SUBDOMAIN.1password.com --email $EMAIL
eval $(op signin --account $SUBDOMAIN)
op whoami

#- Init and apply with chezmoi
# Same command as: chezmoi init --apply https://github.com/larstomas/dotfiles.git
chezmoi init --apply larstomas
