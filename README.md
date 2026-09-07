# dotfiles

My Macs, managed with [chezmoi](https://www.chezmoi.io). Rebuilt from scratch 2026-09-07:
everything in here earned its place by being used (the decision list lives in my vault,
`chezmoi-stadning/`).

## The model

- **Every Mac gets the same configuration.** Files, macOS `defaults`, scripts, 1Password-backed
  templates, Syncthing setup — no per-machine branches.
- **Only the package set differs**, by two traits set at `chezmoi init`:
  - `personal` — asked once: *private Mac, or work Mac?* Private Macs get the `personal` lists,
    work Macs the `work` lists (k8s/cloud CLIs, dev runtimes, Slack …).
  - `bigDisk` — derived: system disk ≥ 400 GB. Gates Xcode.
  - (plus a derived `arm` group: Apple Silicon only — gates tart.)
- **Nothing is decided by hostname.** Anything tied to one named machine (always-on power
  settings, launchd jobs, display/audio apps for a specific desk) lives in the homelab repo
  under `hosts/<name>/`, not here.
- **macOS only.** Linux support was removed in the rebuild (history is in git before it).

## Layout

| Path | What |
|---|---|
| `home/.chezmoi.toml.tmpl` | the two traits + 1Password account email (prompted once) |
| `home/.chezmoidata/packages.yaml` | what to install: `base` (all Macs), `personal`, `work`, `bigDisk`, `arm` |
| `home/.chezmoidata/archived.yaml` | everything ever dropped — history only, installs nothing |
| `home/.chezmoiscripts/` | bootstrap, in order: Touch ID for sudo → Homebrew + packages → 1Password CLI → macOS defaults → Syncthing → cleanup |
| `home/private_dot_config/homelab/`, `kuma/`, `uptimerobot/` | machine-local secrets for the homelab scripts, rendered from 1Password Secure Notes (`op://Personal/homelab-<fil>/text`) |
| `home/private_dot_ssh/config` | one line: `Include ~/Sync/.config/ssh/*` — the host inventory is private and synced, not in this repo |
| `home/dot_claude/`, `home/symlink_dot_agents.tmpl` | Claude Code: `settings.json` is rendered here (*applied*); `CLAUDE.md`, `skills` (via `~/.agents`) and the memory dirs for `~/Sync` and this repo are symlinks into `~/Sync` (*live*, see `CONTEXT.md`). Everything else under `~/.claude` is ignored via `.chezmoiignore` |
| `home/dot_local/bin/executable_mac-maint` | maintenance: `brew update/upgrade`, `brew cu`, `mas upgrade`, cleanup, zinit |
| `tests/macos/` | Tart VM harness for a true fresh-machine test of `install.sh` (optional) |

## Fresh Mac

```sh
sh -c "$(curl -fsLS https://raw.githubusercontent.com/larstomas/dotfiles/main/install.sh)"
```

`install.sh` installs the Xcode Command Line Tools (git), a throwaway chezmoi, then runs
`chezmoi init --apply`. You will be asked for the 1Password account email and whether the Mac
is private; then sudo once (Touch ID from then on); then 1Password must be signed in with
*Settings → Developer → Integrate with 1Password CLI* for the `op://` templates. The log is
`~/.local/state/chezmoi/install-<timestamp>.log`. Sign in to the App Store first so `mas` can
install the App Store apps.

**Existing machine:** if there is already a `chezmoi.toml` from before the rebuild, its
`personal` value is kept — `promptBoolOnce` never re-asks, and `--promptBool` cannot override
a value that is already in the config (it is also keyed on the prompt text, not the variable
name). To re-answer, drop the line and re-run init:

```sh
sed -i '' '/personal/d' ~/.config/chezmoi/chezmoi.toml
chezmoi init --promptBool "Private Mac, not a work Mac=false"   # or =true
```

## Day to day

- `chezmoi status` / `chezmoi diff` / `chezmoi apply` (alias `cs` = status).
- Change what gets installed: edit `packages.yaml`, move dropped entries to `archived.yaml`,
  `chezmoi apply` (the Homebrew script re-runs when its rendered content changes).
- `mac-maint` for upgrades. Homebrew never upgrades during `chezmoi apply`.

## Secret scanning (pre-commit hook)

A `gitleaks` hook in `.githooks/pre-commit` blocks commits that introduce secrets. The hook
path is local git config and is not cloned — enable it once per machine:

```sh
git config core.hooksPath .githooks
```

## Decommissioning a Mac

Deactivate licences: Alfred, Keyboard Maestro, ScreenFlow if installed; sign out of the App
Store, iCloud, Messages, FaceTime, Music/TV, 1Password. Files worth keeping are in `~/Sync`
(Syncthing), not on the machine.
