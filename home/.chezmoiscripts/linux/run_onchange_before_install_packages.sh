#!/bin/bash

#- Error handling 
# [set -e, -u, -o, -x pipefail explanation](https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3945021)
# -e: exit on error
set -euf -o pipefail

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


# Adding ubuntu repositories
sudo add-apt-repository universe -y
sudo add-apt-repository restricted -y
sudo add-apt-repository multiverse -y

echo "# Update reops"
sudo apt update -y

# Basic apps
sudo apt-get install -y build-essential
sudo apt install -y git
sudo apt install -y curl
sudo apt install -y unzip

# Install Font
sudo apt install -y fonts-firacode
#fc-cache -fv # Reload font cache


# Install Z shell (zsh)
sudo apt install -y zsh
# Changed from <sudo chsh -s $(which zsh)> because <which zsh> picked up Homebrews installation of zsh
#sudo chsh -s /usr/bin/zsh
#chsh -s /usr/bin/zsh


#- Install 1Password
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --yes --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --yes --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
sudo apt update -y
sudo apt install -y 1password

# https://developer.1password.com/docs/cli/get-started/#install
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --yes --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list
sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc |  sudo gpg --yes --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
sudo apt update -y
sudo apt install -y 1password-cli
op --version

# https://developer.1password.com/docs/cli/about-biometric-unlock/?utm_medium=organic&utm_source=oph&utm_campaign=linux
sudo groupadd -f onepassword-cli

sudo chown root:onepassword-cli /usr/local/bin/op && \
  sudo chmod g+s /usr/local/bin/op

eval $(op signin --account backman.1password.com)
op read "op://Personal/Github SSH key/public key"

# Install more applications
#sudo apt install -y deborphan                               # deborphan - removing orphaned packages - https://askubuntu.com/questions/389382/command-line-tool-for-removing-orphaned-packages
sudo apt install -y p7zip-full p7zip-rar
#sudo apt install -y smartmontools                           # control and monitor storage systems using S.M.A.R.T.
sudo apt install -y tmux                                    # terminal multiplexer which enables a number of terminals to be created, accessed, and controlled from a single screen.
sudo apt install -y bat
sudo apt install -y ripgrep
sudo apt install -y fd-find
#sudo apt install localepurge                                # Localepurge - removed all localization of the installed packages except for the selected system language.
sudo apt install -y nmap
sudo apt install -y tree
sudo apt install -y btop
sudo apt install -y htop
sudo apt install -y shellcheck                              # lint tool for shell scripts
sudo apt install -y ncdu                                    # Ncdu is a ncurses-based du viewer
sudo apt install -y ranger                                  # Console File Manager with VI Key Bindings. https://ranger.github.io
sudo apt install -y neovim


# VMWare tools
sudo apt install -y open-vm-tools                           # VMWare tools 
sudo apt install -y open-vm-tools-desktop                   # VMWare tools Desktop


# Install VS Code
#sudo snap install -y --classic code

# Install Node and global pachages
#sudo apt install -y npm

#sudo npm install -g tldr


#- Install Homebrew
if command_exists brew; then
  echo "brew exists, skipping install"
else
  echo "brew doesn't exist, continuing with install"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile
  source $HOME/.profile
fi

# Install Homebrew packages
brew install bat
brew install exa
brew install chezmoi
brew install spaceship
brew install yt-dlp
brew install tldr

	
