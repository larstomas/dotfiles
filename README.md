# dotfiles
dotfiles are managed by chezmoi - [Chezmoi Quick Start](https://www.chezmoi.io/quick-start/)

## Inspiration
1. [twpayne/dotfiles: My dotfiles, managed with https://chezmoi.io.](https://github.com/twpayne/dotfiles)
2. [eieioxyz/dotfiles_macos: dotfiles.eieio.xyz](https://github.com/eieioxyz/dotfiles_macos)
3. [How To Setup Your Mac Terminal](https://www.josean.com/posts/terminal-setup)

## Restore Instructions

### 1. Bootstrap (no need to install chezmoi first)

This single command downloads chezmoi to `~/.local/bin`, clones this repo, and applies it.
chezmoi does not need to be installed beforehand.

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b ~/.local/bin init --apply larstomas
```

No `curl`? Use `wget`:

```sh
sh -c "$(wget -qO- https://get.chezmoi.io)" -- -b ~/.local/bin init --apply larstomas
```

(Equivalent to checking out the repo and running `install.sh`, which does the same bootstrap.)

**Logging:** `install.sh` automatically tees the whole bootstrap to
`${XDG_STATE_HOME:-~/.local/state}/chezmoi/install-<timestamp>.log`. To capture the
one-line command above instead, append a `tee`:

```sh
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b ~/.local/bin init --apply larstomas 2>&1 \
  | tee "chezmoi-install-$(date +%Y%m%d-%H%M%S).log"
```

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
