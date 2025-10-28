# --- Weekly zinit maintenance with failure alerts ---------------------------
# XDG_STATE_HOME set in .zshenv
_ZINIT_STATE_DIR="${XDG_STATE_HOME}/zinit"
mkdir -p "$_ZINIT_STATE_DIR"

_STAMP_FILE="$_ZINIT_STATE_DIR/last_maintenance.ts"
_LOG_FILE="$_ZINIT_STATE_DIR/maintenance.log"
_FAIL_FLAG="$_ZINIT_STATE_DIR/last_maintenance_failed"
_INTERVAL=$((7*24*60*60))   # 7 days

# Cross-platform notifier (Linux notify-send, macOS osascript, else stderr)
__zinit_notify_fail() {
  local msg="${1:-zinit maintenance failed}"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "zinit" "$msg"
  elif command -v osascript >/dev/null 2>&1; then
    osascript -e 'display notification '"$(printf %q "$msg")"' with title "zinit"'
  fi
  # Always echo + bell as a last resort
  print -r -- "$msg" >&2
  tput bel 2>/dev/null || true
}

# Show deferred failure (from a previous run) at startup
if [[ -o interactive && -f "$_FAIL_FLAG" ]]; then
  print -r -- "❗ zinit maintenance previously failed. See: $_LOG_FILE" >&2
  rm -f -- "$_FAIL_FLAG" 2>/dev/null
fi

# Read last run timestamp (0 if missing)
if [[ -r "$_STAMP_FILE" ]]; then _LAST_RUN=$(<"$_STAMP_FILE"); else _LAST_RUN=0; fi
_NOW=$EPOCHSECONDS

if (( _NOW - _LAST_RUN >= _INTERVAL )); then
  printf '%s' "$_NOW" >| "$_STAMP_FILE"   # stamp first to avoid double triggers

  (
    {
      echo "[$(date)] zinit maintenance starting..."
      rc=0
      zinit self-update         || rc=$?
      zinit update --parallel   || rc=$(( rc || $? ))
      if (( rc != 0 )); then
        echo "[$(date)] maintenance FAILED with rc=$rc"
        printf '%s' "$rc" >| "$_FAIL_FLAG"
        __zinit_notify_fail "zinit maintenance failed (rc=$rc). Check $_LOG_FILE"
        exit "$rc"
      else
        rm -f -- "$_FAIL_FLAG" 2>/dev/null
        echo "[$(date)] maintenance OK"
      fi
    } >>"$_LOG_FILE" 2>&1
  ) &!   # detach job in zsh
fi
