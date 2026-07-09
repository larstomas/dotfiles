# macOS fresh-machine test harness (Tart VM)

Verify this chezmoi repo in a **throwaway native macOS VM** on an Apple Silicon
host, testing two things:

1. **Fresh bootstrap** — the documented `install.sh` path works from nothing.
2. **Idempotency** — re-applying on a configured machine produces no changes.

The VM is disposable: no iCloud/Apple-Account sign-in, and you delete it when done.
Nothing here is applied to real machines — the chezmoi source root is `home/`
(see `.chezmoiroot`), so this `tests/` tree is ignored by `chezmoi apply`.

## Why Tart

CLI-first wrapper over Apple's Virtualization.framework, with pre-built clean
macOS images on ghcr.io, `tart ip` + SSH for scripting, and `tart delete` for
true throwaway semantics. UTM is GUI-oriented; Apple's sample code needs an app
build + manual `.ipsw`. Tart fits reproducible CLI testing best.

The **vanilla** image tier (`macos-tahoe-vanilla`) has **no Homebrew preinstalled**
— a faithful "brand-new machine". The `base` tier would mask missing-dependency
bugs. Vanilla ships auto-login + SSH enabled, with default creds `admin` / `admin`
(a published throwaway credential, not a real secret).

## Prerequisites (host)

```sh
# Apple Silicon Mac, macOS 13+.  ~25 GB free for the image.
brew install cirruslabs/cli/tart
```

## Files

| File | Runs on | Purpose |
|------|---------|---------|
| `vm-create.sh` | host | (Re)create the VM, boot with GUI, install a throwaway SSH key |
| `install-key.exp` | host | Push the throwaway pubkey using the image's `admin`/`admin` default |
| `clt-install.sh` | VM (SSH) | Headless Xcode CLT install (stands in for the GUI "Install" click) |
| `bootstrap.exp` | host | Drive `install.sh` over `ssh -tt`, capture every prompt, stop at the 1Password wall |
| `run-idempotency.sh` | VM **GUI Terminal** | Finish apply + full idempotency sequence (needs 1Password GUI auth) |
| `run-file-idempotency.sh` | VM **GUI Terminal** | File-only idempotency (`--exclude=scripts`), isolates the file layer |
| `vm-delete.sh` | host | Delete the VM (confirms the name; keeps the cached image by default) |

## Reproducible run

```sh
cd tests/macos

# 1. Create the throwaway VM (image pull is the long pole, ~tens of minutes first time)
VM=chezmoi-test ./vm-create.sh
IP=$(tart ip chezmoi-test); KEY=~/.ssh/chezmoi-vm-test
# Note: the ssh/scp options below pin -o IdentitiesOnly=yes -o IdentityAgent=none so
# an active SSH agent (e.g. 1Password's) can't exhaust sshd's MaxAuthTries with its
# own keys before the -i key is tried (which would disconnect the VM).

# 2. Clean bootstrap over SSH. Stage the headless CLT helper first, then drive install.sh.
scp -i "$KEY" -o IdentitiesOnly=yes -o IdentityAgent=none -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null clt-install.sh admin@"$IP":clt-install.sh
expect ./bootstrap.exp "$IP" "$KEY" /tmp/bootstrap.log
#   exit 42 == reached the 1Password wall (expected on a credential-less machine)

# 3. Sign in to 1Password IN THE VM GUI WINDOW (you do this; the harness never
#    types credentials): open the 1Password app, sign in to backman.1password.com,
#    enable Settings > Developer > "Integrate with 1Password CLI".

# 4. Finish the bootstrap + idempotency test, IN THE VM's GUI Terminal
#    (op desktop integration only authenticates from the GUI login session):
scp -i "$KEY" -o IdentitiesOnly=yes -o IdentityAgent=none -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    run-idempotency.sh run-file-idempotency.sh admin@"$IP":
#    then, inside the VM Terminal window:
#      ~/run-idempotency.sh          # full sequence (scripts included)
#      ~/run-file-idempotency.sh     # file-only idempotency (scripts excluded)
#    watch progress live from the host (optional; open a second terminal):
ssh -i "$KEY" -o IdentitiesOnly=yes -o IdentityAgent=none -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    admin@"$IP" 'tail -n +1 -F ~/cz-idempotency.log' | tr '\r' '\n'
#    (the run ends with ALL_DONE; clean = APPLY1_RC=0, empty status/diff, APPLY2_RC=0)

# 5. Read results back over SSH
scp -i "$KEY" -o IdentitiesOnly=yes -o IdentityAgent=none -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    admin@"$IP":cz-idempotency.log admin@"$IP":cz-file-idempotency.log .

# 6. Teardown (throwaway). Image stays cached, so recreating is cheap.
./vm-delete.sh                 # confirms the VM name; -y to skip the prompt
#   ./vm-delete.sh --remove-key --prune-image   # also drop the key + cached image
```

## Known manual steps / findings this harness surfaces

- **Xcode CLT dialog** — `install.sh` runs `xcode-select --install`, which pops a
  GUI dialog and waits. `clt-install.sh` drives it headlessly; a real machine needs
  a click (or CLT pre-installed) for a hands-off run.
- **`sudo -v` password** — AAB/AAC/macos-config call `sudo -v`, which prompts for a
  password even under `NOPASSWD: ALL` (validation isn't covered by NOPASSWD).
- **1Password is interactive by design** — AAC needs the desktop app + CLI
  integration; `op` authenticates only from the GUI session (not SSH). Once signed
  in, the four `op://` templates render real values.
- **File layer is idempotent**; the script layer only settles once every
  `run_before` script exits 0 (see the repo's `macos-config.zsh` Safari writes,
  which need Full Disk Access or non-fatal guarding).
