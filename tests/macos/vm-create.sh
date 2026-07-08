#!/bin/bash
# Host-side: create a throwaway macOS VM with Tart and give it key-based SSH.
# Idempotent-ish: deletes and recreates the named VM (throwaway by design).
# Requires: Apple Silicon host, Tart (brew install cirruslabs/cli/tart).
set -euo pipefail

VM="${VM:-chezmoi-test}"
IMAGE="${IMAGE:-ghcr.io/cirruslabs/macos-tahoe-vanilla:latest}"
CPU="${CPU:-4}"
MEM="${MEM:-8192}"
KEY="${KEY:-$HOME/.ssh/chezmoi-vm-test}"
HERE="$(cd "$(dirname "$0")" && pwd)"

[ "$(uname -m)" = "arm64" ] || { echo "Host is not Apple Silicon; Tart requires it." >&2; exit 1; }
command -v tart >/dev/null || { echo "Install Tart: brew install cirruslabs/cli/tart" >&2; exit 1; }

echo ">>> (Re)creating VM '$VM' from $IMAGE (image stays cached; recreate is cheap)"
tart delete "$VM" 2>/dev/null || true
tart clone "$IMAGE" "$VM"
tart set "$VM" --cpu "$CPU" --memory "$MEM"

echo ">>> Booting '$VM' WITH a GUI window (needed later for the 1Password sign-in)"
tart run "$VM" >/dev/null 2>&1 &

echo ">>> Waiting for the VM IP..."
IP=""
for _ in $(seq 1 60); do IP="$(tart ip "$VM" 2>/dev/null || true)"; [ -n "$IP" ] && break; sleep 5; done
[ -n "$IP" ] || { echo "VM never got an IP" >&2; exit 1; }
echo ">>> VM IP: $IP"

echo ">>> Waiting for SSH port..."
for _ in $(seq 1 60); do nc -z -w 2 "$IP" 22 2>/dev/null && break; sleep 5; done

[ -f "$KEY" ] || ssh-keygen -t ed25519 -N '' -C chezmoi-vm-test -f "$KEY" -q
echo ">>> Installing throwaway key via the image's default admin/admin"
expect "$HERE/install-key.exp" "$IP" "$KEY.pub"

echo
echo "VM '$VM' ready at $IP. Key: $KEY"
echo "Next:  expect $HERE/bootstrap.exp $IP $KEY /tmp/bootstrap.log"
echo "Teardown when done:  tart delete $VM"
