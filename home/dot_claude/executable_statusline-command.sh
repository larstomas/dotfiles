#!/bin/bash
# Claude Code status line: cwd (~ abbreviated, bold-blue as in ~/.bashrc's
# PS1 \w color) with git branch, followed by model + context-window usage
# and Claude.ai rate-limit usage (5h session limit / 7-day weekly limit /
# 7-day model-specific weekly limit, as shown by /usage).
#
# The model-specific weekly field's exact key isn't documented in the
# statusline JSON schema, so several plausible keys are tried in order
# (dynamic "seven_day_<model family>" first, then known legacy names) and
# the segment is simply omitted if none are present.

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
[ -z "$cwd" ] && cwd="$PWD"

# Shorten $HOME to ~ (bash's \w does this natively)
display_cwd="${cwd/#$HOME/\~}"

branch=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
fi
[ -n "$branch" ] && display_cwd="$display_cwd ($branch)"

model=$(echo "$input" | jq -r '.model.display_name // empty')
used_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

context_str=""
if [ -n "$used_tokens" ] && [ -n "$used_pct" ]; then
  used_k=$(( (used_tokens + 500) / 1000 ))
  used_pct_round=$(printf '%.0f' "$used_pct")
  context_str="${used_k}K (${used_pct_round}%)"
fi

model_str=""
if [ -n "$model" ] && [ -n "$context_str" ]; then
  model_str=" | [$model] $context_str"
elif [ -n "$model" ]; then
  model_str=" | [$model]"
elif [ -n "$context_str" ]; then
  model_str=" | $context_str"
fi

five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Model-specific weekly limit (e.g. the separate "weekly Opus/Fable limit"
# shown in /usage). Key name isn't documented, so try a few candidates.
family=$(echo "$model" | awk '{print tolower($1)}')
model_week=""
if [ -n "$family" ]; then
  model_week=$(echo "$input" | jq -r --arg fam "$family" '
    .rate_limits[("seven_day_" + $fam)].used_percentage
    // .rate_limits[("seven_day_" + $fam + "_apps")].used_percentage
    // .rate_limits.seven_day_opus.used_percentage
    // .rate_limits.seven_day_oauth_apps.used_percentage
    // .rate_limits.model_seven_day.used_percentage
    // .rate_limits.seven_day_model.used_percentage
    // empty
  ')
fi

rate_str=""
[ -n "$five_h" ] && rate_str="$rate_str | 5h: $(printf '%.0f' "$five_h")%"
[ -n "$week" ] && rate_str="$rate_str | wk: $(printf '%.0f' "$week")%"
[ -n "$model_week" ] && [ -n "$family" ] && rate_str="$rate_str | ${family}: $(printf '%.0f' "$model_week")%"

printf '\033[01;34m%s\033[00m%s%s' "$display_cwd" "$model_str" "$rate_str"
