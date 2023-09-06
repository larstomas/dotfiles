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


# Inspiration:
# [eieioxyz/dotfiles_macos: dotfiles.eieio.xyz](https://github.com/eieioxyz/dotfiles_macos)

#- Functions
function command_exists() {
  # `command -v` is similar to `which`
  # https://stackoverflow.com/a/677212/1341838
  command -v $1 >/dev/null 2>&1
}


#- Install Homebrew
if command_exists brew; then
  echo "brew exists, skipping install"
else
  echo "brew doesn't exist, continuing with install"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if $(arch) = "i386";then
    echo "Setup Homebrew for x86"
    eval "$(/usr/local/bin/brew shellenv)"
  else
    echo "Setup Homebrew for ARM"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi


#- Install Homebrew with applications
#source ./scripts/setup_homebrew_macos.zsh
export HOMEBREW_CASK_OPTS="--no-quarantine"

brew bundle --no-lock --file=/dev/stdin <<EOF
tap "1password/tap"
tap "homebrew/bundle"
tap "homebrew/cask-fonts"
brew "chezmoi"
brew "exa"
brew "eza"
brew "spaceship"
brew "zsh"
cask "1password"
cask "1password-cli"
cask "appcleaner"
mas "1Password for Safari", id: 1569813296
mas "Accelerate", id: 1459809092
mas "Amphetamine", id: 937984704
EOF

