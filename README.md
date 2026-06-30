# dotfiles
dotfiles are managed by chezmoi - [Chezmoi Quick Start](https://www.chezmoi.io/quick-start/)

## Inspiration
1. [twpayne/dotfiles: My dotfiles, managed with https://chezmoi.io.](https://github.com/twpayne/dotfiles)
2. [eieioxyz/dotfiles_macos: dotfiles.eieio.xyz](https://github.com/eieioxyz/dotfiles_macos)
3. [How To Setup Your Mac Terminal](https://www.josean.com/posts/terminal-setup)

## Restore Instructions

### 1. Bootstrap (no need to install chezmoi first)

**Fresh macOS (no git yet)** — use `install.sh`. chezmoi needs git to clone this
repo, and git comes from the Xcode Command Line Tools, so `install.sh` installs
those first, then installs chezmoi and applies:

```sh
sh -c "$(curl -fsLS https://raw.githubusercontent.com/larstomas/dotfiles/main/install.sh)"
```

**If git is already present**, the plain chezmoi one-liner works too:

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply larstomas
```

(`wget` users: swap in `"$(wget -qO- <url>)"`.)

Notes:
- The downloaded chezmoi is a **throwaway** (`./bin/chezmoi`). During apply, Homebrew
  installs the permanent chezmoi (`AAB-install-homebrew`), and the
  `zzz-cleanup-bootstrap-chezmoi` script removes the throwaway automatically.
- `install.sh` tees the whole run to
  `${XDG_STATE_HOME:-~/.local/state}/chezmoi/install-<timestamp>.log`.

### 2. Apps and settings
1. Sign in to App Store first, so apps install via the `mas` command.
2. In Terminal.app, restore app settings via the wrapper script (it unzips the backup, then runs `mackup restore`):
   1. Take `mackup-backup.zip` from backup.
   2. Place it in `~/Downloads`
   3. Run: `scripts/mackup-restore-app-settings.zsh` *OBS*: All old settings will be destroyed. (Tip: preview first with `mackup restore --dry-run --verbose`.)

## Secret Scanning (pre-commit hook)
A `gitleaks` pre-commit hook (`.githooks/pre-commit`) blocks commits that introduce
secrets. `gitleaks` is installed automatically via the Homebrew bootstrap script.

The hook lives in the tracked `.githooks/` directory, but `core.hooksPath` is local
git config and is **not** cloned. Enable it once per machine:

```sh
git config core.hooksPath .githooks
```

Bypass for a single commit (use sparingly): `git commit --no-verify`.

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
- Music / TV
- 1Password
