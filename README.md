# dotfiles
My dotfiles are managed by chezmoi - [Chezmoi Quick Start](https://www.chezmoi.io/quick-start/)

## TODO
1. [LunarVim  Quick start](https://www.lunarvim.org/docs/quick-start)
2. Add .ssh in chezmoi
3. Use Brewfile and upgrade with homebrew
4. Run application installations with chezmoi
5. Gå igenom https://github.com/eieioxyz/dotfiles_macos

## Inspiration
1. [eieioxyz/dotfiles_macos: dotfiles.eieio.xyz](https://github.com/eieioxyz/dotfiles_macos)
2. [How To Setup Your Mac Terminal](https://www.josean.com/posts/terminal-setup)

## Restore Instructions
Exempel: https://github.com/eieioxyz/dotfiles_macos#decommission-computer

1. Sign in to App Store to be able to install apps via "mas" command
2. Run: `2. chezmoi init --apply https://github.com/larstomas/dotfiles.git`
3. Set up 1password with github: https://developer.1password.com/docs/cli/shell-plugins/github/
4. [Use 1Password to securely authenticate GitHub | 1Password Developer](https://developer.1password.com/docs/cli/shell-plugins/github/)
5. TODO check 1password config in .zshenv

## Decommission Computer
Exempel: https://github.com/eieioxyz/dotfiles_macos#restore-instructions

1. Log out of Dropbox
2. Log out of iCloud
3. Log out of Music/iTunes 
4. Log out of Messages and Facetime
