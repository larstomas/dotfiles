#!/usr/bin/env zsh

echo "\n<<< Starting Homebrew Setup >>>\n"

echo "#- Install Homebrew"
if command_exists brew; then
  echo "brew exists, skipping install"
else
  echo "brew doesn't exist, continuing with install"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export HOMEBREW_CASK_OPTS="--no-quarantine" 

# Should we wrap this in a conditional?
echo "Enter superuser (sudo) password to accept Xcode license"
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch

# This works to solve the Insecure Directories issue:
# compaudit | xargs chmod go-w
# But this is from the Homebrew site, though `-R` was needed:
# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
#chmod -R go-w "$(brew --prefix)/share"

echo "#- Install software"
# Read more on [Brew Bundle Brewfile Tips](https://gist.github.com/ChristopherA/a579274536aab36ea9966f301ff14f3f)
brew bundle --verbose --file ../dot_dotfiles/Brewfile

# VS code is syncing via github
# Otherwise export vscode extensions
# code --list-extensions
# and:
#echo "#- Installing VS Code Extensions"
#cat vscode_extensions | xargs -L 1 code --install-extension
