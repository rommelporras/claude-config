#!/usr/bin/env bash
# PreToolUse/Bash hook: remind about tmux for long-running commands
# Fires when a long-running command is detected and we're not in tmux

set -euo pipefail

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

# Only warn if not already in tmux
if [ -n "$TMUX" ]; then
  echo "$INPUT"
  exit 0
fi

# Check for long-running command patterns
if echo "$CMD" | grep -qE '(npm (install|test|run build)|pnpm (install|test|run build)|bun (install|test|run build)|cargo build|make\b|docker (build|compose)|pytest|vitest run|playwright test)'; then
  echo "[Hook] Consider running in tmux for session persistence" >&2
  echo "[Hook] tmux new -s dev  |  tmux attach -t dev" >&2
fi

echo "$INPUT"
