#!/bin/bash

#- Error handling 
# [set -e, -u, -o, -x pipefail explanation](https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425?permalink_comment_id=3945021)
# -e: exit on error
set -euf -o pipefail

echo "#- Redirect STDOUT and STDERR to log file"
exec 1>>$HOME/Downloads/install.log
exec 2>&1

echo "#- Ask for admin password upfront"
sudo -v
# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

#- Functions
function command_exists() {
  # `command -v` is similar to `which`
  # https://stackoverflow.com/a/677212/1341838
  command -v $1 >/dev/null 2>&1
}

echo "#- Adding ubuntu repositories"
sudo add-apt-repository universe -y
sudo add-apt-repository restricted -y
sudo add-apt-repository multiverse -y

echo "#- Update reops"
sudo apt-get update -y

echo "#- Basic apps"
sudo apt-get install -y build-essential
sudo apt-get install -y git
sudo apt-get install -y curl
sudo apt-get install -y unzip

echo "#- Install Font"
sudo apt-get install -y fonts-firacode
fc-cache -fv # Reload font cache

echo '#- Install Z shell (zsh)'
sudo apt-get install -y zsh
set_shell="zsh"
if [[ "${SHELL,,}" != *"$set_shell"* ]]; then
  echo "# Change to $set_shell"
  if [[ "$(which $set_shell)" == *"brew"* ]]; then
    echo "# <which $set_shell> pick up Homebrews installation of $set_shell"
    echo "# Change user and root shell to /usr/bin/$set_shell in /etc/passwd"
    sudo chsh -s /usr/bin/$set_shell $(whoami)
    sudo chsh -s /usr/bin/$set_shell root
  else
    echo "# Change useing $(which $set_shell)"
    sudo chsh -s $(which $set_shell) $(whoami)
    sudo chsh -s $(which $set_shell) root
  fi
fi
echo "# Set shell to $set_shell ended"


echo "#- Install more applications"
sudo apt-get install -y bat
  mkdir -p ~/.local/bin                                      # ... the executable may be installed as batcat instead of bat...
  ln -sf /usr/bin/batcat ~/.local/bin/bat                    # [sharkdp/bat: A cat(1) clone with wings.](https://github.com/sharkdp/bat#on-ubuntu-using-apt)
#sudo apt-get install -y deborphan                               # deborphan - removing orphaned packages - https://askubuntu.com/questions/389382/command-line-tool-for-removing-orphaned-packages
sudo apt-get install -y p7zip-full p7zip-rar
#sudo apt-get install -y smartmontools                           # control and monitor storage systems using S.M.A.R.T.
sudo apt-get install -y tmux                                    # terminal multiplexer which enables a number of terminals to be created, accessed, and controlled from a single screen.
sudo apt-get install -y ripgrep
sudo apt-get install -y fd-find
#sudo apt-get install localepurge                                # Localepurge - removed all localization of the installed packages except for the selected system language.
sudo apt-get install -y nmap
sudo apt-get install -y tree
sudo apt-get install -y btop
sudo apt-get install -y htop
sudo apt-get install -y shellcheck                              # lint tool for shell scripts
sudo apt-get install -y ncdu                                    # Ncdu is a ncurses-based du viewer
sudo apt-get install -y ranger                                  # Console File Manager with VI Key Bindings. https://ranger.github.io
sudo apt-get install -y neovim
sudo apt-get install -y exa


echo "#- VMWare tools"
sudo apt-get install -y open-vm-tools                           # VMWare tools 
sudo apt-get install -y open-vm-tools-desktop                   # VMWare tools Desktop


echo "#- Install VS Code"
sudo snap install --classic code


echo "#- Install Node and global pachages"
#sudo apt-get install -y npm

#sudo npm install -g tldr


echo "#- Install Homebrew"
if command_exists brew; then
  echo "# brew exists, skipping install"
else
  echo "# brew doesn't exist, continuing with install"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "eval \"\$($(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >> ~/.profile
  source $HOME/.profile
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

echo "#- Install Homebrew packages"
brew install chezmoi
brew install yt-dlp
brew install tldr


echo "#- Install 1Password"
sudo apt-get install policykit-1  # Requirement: https://developer.1password.com/docs/cli/get-started/

# https://developer.1password.com/docs/cli/get-started/#install
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --yes --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list >/dev/null
sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol >/dev/null
sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --yes --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
sudo apt-get update -y

echo "#-- Install 1Password Desktop"
sudo apt-get install -y 1password

echo "#-- Install 1Password CLI"
# https://developer.1password.com/docs/cli/about-biometric-unlock/?utm_medium=organic&utm_source=oph&utm_campaign=linux
sudo groupadd -f onepassword-cli
sudo chown root:onepassword-cli /usr/local/bin/op && sudo chmod g+s /usr/local/bin/op
sudo apt-get install -y 1password-cli

echo "#-- Install 1Password Github Plugin"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt-get update
sudo apt-get install -y gh

echo "#-- Test 1Password installation"
op --version
# Login
eval $(op signin --account backman.1password.com)
# Test read from 1password
op read "op://Personal/test_read_from_1password_vault/text"

echo "#-- Setup 1Password GitHub plugin"
op plugin init gh 
gh auth login

#echo "#- Install Tabby Terminal"
#sudo apt-get install -y wget apt-transport-https
#curl -s https://packagecloud.io/install/repositories/eugeny/tabby/script.deb.sh | sudo bash
#sudo apt-get install -y tabby-terminal
