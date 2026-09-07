# dotfiles

The chezmoi source for every Mac Tomas uses. It decides *how* a Mac is configured; the private
content it points at lives in `~/Sync` and is synced by Syncthing.

## Language

**Trait**:
One of the two facts asked or derived at `chezmoi init` (`personal`, `bigDisk`) that select
package lists. Never a hostname.
_Avoid_: profile, role, machine type

**Tier**:
A named package list in `packages.yaml` gated by traits: `base`, `personal`, `work`, `bigDisk`, `arm`.
_Avoid_: group, bundle, level

**Mechanism**:
What this repo owns: the files, symlinks, scripts and templates that put configuration in place.
Public.
_Avoid_: setup, structure

**Content**:
What the mechanism points at but does not contain: ssh host inventory, Claude rules, skills,
memory. Lives in `~/Sync`, private, never in this repo.
_Avoid_: data, payload

**Live**:
Content reached through a symlink into `~/Sync`. A change on one Mac appears on the others
through Syncthing within a minute, with no `chezmoi apply`. Two Macs writing the same file at
once produce a `.sync-conflict` copy.
_Avoid_: synced, shared, linked

**Applied**:
A file rendered by chezmoi from this repo and only changed by commit + `chezmoi apply`. Used
where a program writes the file itself, so that Syncthing never sees concurrent writes.
_Avoid_: managed, templated, static

**Hub**:
mattis, the only Syncthing peer any Mac talks to. Macs never sync directly with each other.
_Avoid_: server, master
