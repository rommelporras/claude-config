#!/usr/bin/env bash
# SessionStart hook: load previous session context
#
# On new session, finds the most recent session file and injects it
# into Claude's context via stdout. This gives Claude awareness of
# what was being worked on previously.

set -euo pipefail

SESSIONS_DIR="$HOME/.claude/sessions"

if [ ! -d "$SESSIONS_DIR" ]; then
  exit 0
fi

# Find most recent session file (within last 7 days)
LATEST=$(find "$SESSIONS_DIR" -name "*-session.md" -mtime -7 -type f 2>/dev/null | sort -r | head -1)

if [ -z "$LATEST" ]; then
  exit 0
fi

CONTENT=$(cat "$LATEST")

# Only inject if it has actual content (not just the template)
if [ -n "$CONTENT" ]; then
  echo "[SessionStart] Loading previous session from $(basename "$LATEST")" >&2
  echo "Previous session context:"
  echo "$CONTENT"
fi
