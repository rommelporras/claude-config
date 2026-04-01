#!/usr/bin/env bash
# Claude Code status line — Claude-specific info only (Starship handles the rest)
# Receives JSON on stdin from Claude Code

input=$(cat)

# ── Parse all fields with a single jq call ────────────────────────────────────
eval "$(echo "$input" | jq -r '
  @sh "cwd=\(.workspace.current_dir // .cwd // "")",
  @sh "model=\(.model.display_name // "")",
  @sh "remaining=\(.context_window.remaining_percentage // "")",
  @sh "cost=\(.cost.total_cost_usd // "")",
  @sh "duration_ms=\(.cost.total_duration_ms // "")",
  @sh "lines_added=\(.cost.total_lines_added // "")",
  @sh "lines_removed=\(.cost.total_lines_removed // "")",
  @sh "rate_5h=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "worktree_name=\(.worktree.name // "")",
  @sh "agent_name=\(.agent.name // "")"
')"

# ── Colors ────────────────────────────────────────────────────────────────────
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
PURPLE='\033[35m'
DIM='\033[2m'
RESET='\033[0m'
SEP="${DIM} │${RESET}"

line=""

# project directory (~ shortened)
if [ -n "$cwd" ]; then
    home_resolved=$(eval echo "~")
    cwd="${cwd/#$home_resolved/\~}"
    line+="$(printf "${YELLOW}%s${RESET}" "$cwd")"
fi

# model
if [ -n "$model" ]; then
    line+="$(printf " ${DIM}[${RESET}${CYAN}%s${RESET}${DIM}]${RESET}" "$model")"
fi

# context window remaining (color-coded)
if [ -n "$remaining" ]; then
    pct=$(printf "%.0f" "$remaining")
    if [ "$pct" -gt 50 ]; then
        ctx_color="${GREEN}"
    elif [ "$pct" -gt 20 ]; then
        ctx_color="${YELLOW}"
    else
        ctx_color="${RED}"
    fi
    line+="$(printf " ${DIM}context${RESET} ${ctx_color}%s%%${RESET}" "$pct")"
fi

# session cost
if [ -n "$cost" ] && [ "$cost" != "0" ]; then
    formatted_cost=$(printf "%.2f" "$cost")
    line+="$(printf "${SEP} ${DIM}cost${RESET} \$%s" "$formatted_cost")"
fi

# lines changed
if [ -n "$lines_added" ] || [ -n "$lines_removed" ]; then
    added="${lines_added:-0}"
    removed="${lines_removed:-0}"
    if [ "$added" -gt 0 ] || [ "$removed" -gt 0 ]; then
        line+="$(printf "${SEP} ${DIM}lines${RESET} ${GREEN}+%s${RESET} ${RED}-%s${RESET}" "$added" "$removed")"
    fi
fi

# rate limit (5-hour window)
if [ -n "$rate_5h" ]; then
    rate_pct=$(printf "%.0f" "$rate_5h")
    if [ "$rate_pct" -gt 80 ]; then
        rate_color="${RED}"
    elif [ "$rate_pct" -gt 50 ]; then
        rate_color="${YELLOW}"
    else
        rate_color="${DIM}"
    fi
    line+="$(printf "${SEP} ${rate_color}limit %s%%/5h${RESET}" "$rate_pct")"
fi

# session duration
if [ -n "$duration_ms" ]; then
    total_secs=$((duration_ms / 1000))
    hours=$((total_secs / 3600))
    mins=$(( (total_secs % 3600) / 60 ))
    if [ "$hours" -gt 0 ]; then
        duration="${hours}h${mins}m"
    else
        duration="${mins}m"
    fi
    line+="$(printf "${SEP} ${DIM}%s${RESET}" "$duration")"
fi

# worktree indicator
if [ -n "$worktree_name" ]; then
    line+="$(printf "${SEP} ${PURPLE}wt:%s${RESET}" "$worktree_name")"
fi

# agent indicator
if [ -n "$agent_name" ]; then
    line+="$(printf "${SEP} ${CYAN}agent:%s${RESET}" "$agent_name")"
fi

printf "%b\n" "$line"
