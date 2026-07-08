#!/bin/bash
# Host-side: delete the throwaway macOS test VM created by vm-create.sh.
# Safe by default: confirms the VM name before deleting, keeps the cached base
# image (so recreating is cheap), and leaves the throwaway SSH key in place
# unless asked otherwise.
#
# Usage:
#   ./vm-delete.sh                 # delete VM 'chezmoi-test' (asks to confirm)
#   VM=my-vm ./vm-delete.sh        # target a different VM name
#   ./vm-delete.sh -y              # no prompt (for scripts/CI)
#   ./vm-delete.sh --remove-key    # also delete the throwaway SSH key pair
#   ./vm-delete.sh --prune-image   # also delete the cached base OCI image
set -euo pipefail

VM="${VM:-chezmoi-test}"
IMAGE="${IMAGE:-ghcr.io/cirruslabs/macos-tahoe-vanilla:latest}"
KEY="${KEY:-$HOME/.ssh/chezmoi-vm-test}"
ASSUME_YES=0
REMOVE_KEY=0
PRUNE_IMAGE=0
for arg in "$@"; do
  case "$arg" in
    -y|--yes)      ASSUME_YES=1 ;;
    --remove-key)  REMOVE_KEY=1 ;;
    --prune-image) PRUNE_IMAGE=1 ;;
    -h|--help)     sed -n '2,13p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

command -v tart >/dev/null || { echo "tart not installed; nothing to delete." >&2; exit 0; }

# Only ever touch a local VM that actually exists (never an OCI image row).
if ! tart list --source local --quiet 2>/dev/null | grep -Fxq -- "$VM"; then
  echo "No local VM named '$VM' found. Current VMs:"
  tart list || true
  exit 0
fi

echo "About to permanently delete local VM: '$VM'"
if [ "$ASSUME_YES" -ne 1 ]; then
  printf "Type the VM name to confirm deletion: "
  read -r reply
  [ "$reply" = "$VM" ] || { echo "Name mismatch ('$reply' != '$VM') — aborting, nothing deleted."; exit 1; }
fi

echo ">>> Stopping '$VM' (ignored if already stopped)"
tart stop "$VM" 2>/dev/null || true
echo ">>> Deleting '$VM'"
tart delete "$VM"
echo ">>> VM '$VM' deleted."

if [ "$REMOVE_KEY" -eq 1 ]; then
  echo ">>> Removing throwaway SSH key: $KEY{,.pub}"
  rm -f "$KEY" "$KEY.pub"
fi

if [ "$PRUNE_IMAGE" -eq 1 ]; then
  echo ">>> Pruning cached base image: $IMAGE"
  tart delete "$IMAGE" 2>/dev/null || true
else
  echo "(kept cached base image; re-create is cheap. Use --prune-image to remove it.)"
fi

echo "Delete complete."
