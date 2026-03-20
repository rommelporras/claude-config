#!/usr/bin/env bash
# Claude Code status line — mirrors Starship prompt layout
# Receives JSON on stdin from Claude Code

input=$(cat)

# ── Identity ──────────────────────────────────────────────────────────────────
user=$(whoami)
host=$(hostname -s)

# ── Working directory (from JSON, shortened like Starship truncation_length=5) ─
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
if [ -n "$cwd" ]; then
    # Replace $HOME prefix with ~
    cwd="${cwd/#$HOME/~}"
    # Truncate to last 5 path components (matching starship truncation_length=5)
    IFS='/' read -ra parts <<< "$cwd"
    count=${#parts[@]}
    if [ "$count" -gt 5 ]; then
        cwd="…/${parts[*]: -5}"
        cwd="${cwd// //}"
    fi
else
    cwd=$(pwd)
    cwd="${cwd/#$HOME/~}"
fi

# ── Git branch (skip optional locks) ─────────────────────────────────────────
git_branch=""
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // empty')
if [ -n "$project_dir" ] && [ -d "$project_dir/.git" ]; then
    git_branch=$(git -C "$project_dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || \
                 git -C "$project_dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
fi

# ── Model display name ────────────────────────────────────────────────────────
model=$(echo "$input" | jq -r '.model.display_name // empty')

# ── Context window remaining ──────────────────────────────────────────────────
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# ── Build output ──────────────────────────────────────────────────────────────
# ANSI colours (will render dimmed in the status line area)
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
PURPLE='\033[35m'
DIM='\033[2m'
RESET='\033[0m'

line=""

# user@host
line+="$(printf "${CYAN}%s${RESET}${DIM}@${RESET}${GREEN}%s${RESET}" "$user" "$host")"

# directory
line+="$(printf " ${DIM}in${RESET} ${YELLOW}%s${RESET}" "$cwd")"

# git branch
if [ -n "$git_branch" ]; then
    line+="$(printf " ${DIM}on${RESET} ${PURPLE} %s${RESET}" "$git_branch")"
fi

# model
if [ -n "$model" ]; then
    line+="$(printf " ${DIM}[${RESET}%s${DIM}]${RESET}" "$model")"
fi

# context window remaining
if [ -n "$remaining" ]; then
    # Colour the percentage: green >50%, yellow 20-50%, red <20%
    pct=$(printf "%.0f" "$remaining")
    if [ "$pct" -gt 50 ]; then
        ctx_color="${GREEN}"
    elif [ "$pct" -gt 20 ]; then
        ctx_color="${YELLOW}"
    else
        ctx_color='\033[31m'  # red
    fi
    line+="$(printf " ${DIM}ctx${RESET} ${ctx_color}%s%%${RESET}" "$pct")"
fi

printf "%b\n" "$line"
