#!/bin/sh
# Claude Code hook: mirror the session's state in the tmux window name.
#   busy  - prefix the window name with "*" (UserPromptSubmit)
#   idle  - strip the "*"                   (Stop, StopFailure)
#   end   - give the name back to tmux's automatic-rename (SessionEnd)
# ~/.claude/statusline-command.sh sets the name itself from the session name
# and keeps a leading "*" when it does. Hooks must never fail, so exit 0.
cat >/dev/null
[ -n "${TMUX_PANE:-}" ] || exit 0
name=$(tmux display-message -p -t "$TMUX_PANE" '#{window_name}' 2>/dev/null) || exit 0
base="${name#\*}"
case "${1:-}" in
  busy) [ "$base" = "$name" ] && tmux rename-window -t "$TMUX_PANE" "*$name" ;;
  idle) [ "$base" != "$name" ] && tmux rename-window -t "$TMUX_PANE" "$base" ;;
  end) tmux set-option -w -t "$TMUX_PANE" automatic-rename on ;;
esac
exit 0
