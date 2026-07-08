#!/bin/bash
# Complete the chezmoi bootstrap + run the idempotency test. Run in the VM's GUI
# Terminal (Terminal.app), NOT over SSH: 1Password desktop CLI integration can only
# authenticate from the GUI login session. All output is tee'd to a log the host
# reads back over SSH. Deliberately no `set -e` -- capture the full sequence even
# if a step reports changes.
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
cd "$HOME" || exit 1
LOG="$HOME/cz-idempotency.log"
: > "$LOG"
section() { printf '\n===== %s =====\n' "$*" | tee -a "$LOG"; }

section "op whoami (approve the 1Password prompt in the VM if it appears)"
op whoami 2>&1 | tee -a "$LOG"; echo "WHOAMI_RC=${PIPESTATUS[0]}" | tee -a "$LOG"

section "APPLY 1 -- complete bootstrap (AAC + remaining scripts, renders op:// templates)"
chezmoi apply -v 2>&1 | tee -a "$LOG"; echo "APPLY1_RC=${PIPESTATUS[0]}" | tee -a "$LOG"

section "chezmoi status  (idempotency: expect EMPTY)"
chezmoi status 2>&1 | tee -a "$LOG"; echo "STATUS_RC=${PIPESTATUS[0]}" | tee -a "$LOG"

section "chezmoi diff  (idempotency: expect EMPTY)"
chezmoi diff 2>&1 | tee -a "$LOG"; echo "DIFF_RC=${PIPESTATUS[0]}" | tee -a "$LOG"

section "APPLY 2 dry-run (chezmoi apply -n -v: expect no changes listed)"
chezmoi apply -n -v 2>&1 | tee -a "$LOG"; echo "APPLY2DRY_RC=${PIPESTATUS[0]}" | tee -a "$LOG"

section "APPLY 2 real (chezmoi apply -v: expect no changes / no script re-runs)"
chezmoi apply -v 2>&1 | tee -a "$LOG"; echo "APPLY2_RC=${PIPESTATUS[0]}" | tee -a "$LOG"

section "chezmoi status after 2nd apply (expect EMPTY)"
chezmoi status 2>&1 | tee -a "$LOG"

section "ALL_DONE"
echo "Wrote $LOG"
