#!/usr/bin/env zsh

# Inspiration:
# [eieioxyz/dotfiles_macos: dotfiles.eieio.xyz](https://github.com/eieioxyz/dotfiles_macos)

echo "# Starting Homebrew Setup"

function command_exists() {
  # `command -v` is similar to `which`
  # https://stackoverflow.com/a/677212/1341838
  command -v $1 >/dev/null 2>&1
}

if command_exists brew; then
  echo "brew exists, skipping install"
else
  echo "brew doesn't exist, continuing with install"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if $(arch) = "i386";then 
    echo "Setup Homebrew for x86"
    eval "$(/usr/local/bin/brew shellenv)"
  else
    echo "Setup Homebrew for ARM"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

export HOMEBREW_CASK_OPTS="--no-quarantine" 

# This works to solve the Insecure Directories issue:
# compaudit | xargs chmod go-w
# But this is from the Homebrew site, though `-R` was needed:
# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
#chmod -R go-w "$(brew --prefix)/share"

echo "# Start installing my applications"
# Read more on [Brew Bundle Brewfile Tips](https://gist.github.com/ChristopherA/a579274536aab36ea9966f301ff14f3f)
time brew bundle --verbose --file ./scripts/Brewfile

# VS code is syncing via github
# Otherwise export vscode extensions
# code --list-extensions > extensions.list
# and:
#echo "#- Installing VS Code Extensions"
#cat vscode_extensions | xargs -L 1 code --install-extension
