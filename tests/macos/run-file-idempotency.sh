#!/bin/bash
# Isolate FILE idempotency from the script layer. `--exclude=scripts` applies only
# managed files (still renders op:// templates, using the cached 1Password session)
# and skips run scripts -- useful when a run_before script (e.g. macos-config.zsh)
# aborts apply before the file stage is reached. Run twice; the 2nd apply + status
# + diff must be empty for the file layer to be idempotent. Run in the VM GUI
# Terminal (approve the 1Password prompt if it reappears).
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
cd "$HOME" || exit 1
LOG="$HOME/cz-file-idempotency.log"
: > "$LOG"
section() { printf '\n===== %s =====\n' "$*" | tee -a "$LOG"; }

section "op whoami (approve 1Password prompt if it appears)"
op whoami 2>&1 | tee -a "$LOG"; echo "WHOAMI_RC=${PIPESTATUS[0]}" | tee -a "$LOG"

section "FILE APPLY 1 (chezmoi apply --exclude=scripts -v) -- applies dotfiles incl. op:// templates"
chezmoi apply --exclude=scripts -v 2>&1 | tee -a "$LOG"; echo "FAPPLY1_RC=${PIPESTATUS[0]}" | tee -a "$LOG"

section "chezmoi status --exclude=scripts (expect EMPTY)"
chezmoi status --exclude=scripts 2>&1 | tee -a "$LOG"; echo "FSTATUS_RC=${PIPESTATUS[0]}" | tee -a "$LOG"

section "chezmoi diff --exclude=scripts (expect EMPTY)"
chezmoi diff --exclude=scripts 2>&1 | tee -a "$LOG"; echo "FDIFF_RC=${PIPESTATUS[0]}" | tee -a "$LOG"

section "FILE APPLY 2 (chezmoi apply --exclude=scripts -v) -- expect NO changes"
chezmoi apply --exclude=scripts -v 2>&1 | tee -a "$LOG"; echo "FAPPLY2_RC=${PIPESTATUS[0]}" | tee -a "$LOG"

section "full chezmoi status (incl scripts, for reference)"
chezmoi status 2>&1 | tee -a "$LOG"

section "ALL_DONE_FILE"
echo "Wrote $LOG"
