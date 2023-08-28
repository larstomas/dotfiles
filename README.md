# dotfiles
dotfiles are managed by chezmoi - [Chezmoi Quick Start](https://www.chezmoi.io/quick-start/)

## Inspiration
1. [twpayne/dotfiles: My dotfiles, managed with https://chezmoi.io.](https://github.com/twpayne/dotfiles)
2. [eieioxyz/dotfiles_macos: dotfiles.eieio.xyz](https://github.com/eieioxyz/dotfiles_macos)
3. [How To Setup Your Mac Terminal](https://www.josean.com/posts/terminal-setup)

## Restore Instructions
1. Sign in to App Store to be able to install apps via `mas` command
2. Download zipped version of https://github.com/larstomas/dotfiles
3. Run `install.sh`
4. With Terminal.app. Run `mackup restore`. Consider doing a `mackup restore --dry-run --verbose` first
   1. Take `mackup-backup.zip` from backup.
   2. Place `it in ~/Downloads`
   3. Run: `scripts/mackup-restore-app-settings.zsh` *OBS*: All old settings will be destroyed.

## Decommission Computer
1. Make a backup of settings with [mackup](https://github.com/lra/mackup)
   1. Run `scripts/mackup-backup-app-settings.zsh`
   2. Backup files will be put in `~/Downloads`

Deactivate licenses:
- Dropbox (Preferences > Account > Unlink)
- ScreenFlow (Preferences > Licenses > Deactivate)
- Sign Out of App Store (Menu > Store > Sign Out)
  - Messages
  - Facetime
  - iCloud
- iTunes
- 1Password

## TODO
- Set $XDG_CONFIG_HOME in linux
- export PATH="/snap/bin:$PATH"       for debian

