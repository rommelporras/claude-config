#!/usr/bin/env bash
# PreCompact + Stop hook: save session state for cross-session continuity
#
# PreCompact: captures state before context compaction
# Stop: updates session file after each response (lightweight)
#
# Session files live in ~/.claude/sessions/ and are loaded by session-load.sh
# on the next SessionStart.

set -euo pipefail

SESSIONS_DIR="$HOME/.claude/sessions"
mkdir -p "$SESSIONS_DIR"

TODAY=$(date +%Y-%m-%d)
SESSION_FILE="$SESSIONS_DIR/$TODAY-session.md"

# Get project context
PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
WORKTREE=$(pwd)

# Get modified files
MODIFIED_FILES=$(git diff --name-only HEAD 2>/dev/null || echo "none")
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "none")

# Get recent commits (last 5)
RECENT_COMMITS=$(git log --oneline -5 2>/dev/null || echo "none")

TIMESTAMP=$(date +%H:%M:%S)

if [ -f "$SESSION_FILE" ]; then
  # Update existing session file — replace the auto-generated section
  # Keep everything before the separator, regenerate the rest
  # Use a temp file to avoid partial writes
  TEMP_FILE=$(mktemp)

  cat > "$TEMP_FILE" << ENDOFTEMPLATE
# Session: $TODAY

**Project:** $PROJECT_NAME
**Branch:** $BRANCH
**Worktree:** $WORKTREE
**Last Updated:** $TIMESTAMP

---

## Modified Files (unstaged)
$(echo "$MODIFIED_FILES" | sed 's/^/- /')

## Staged Files
$(echo "$STAGED_FILES" | sed 's/^/- /')

## Recent Commits
$(echo "$RECENT_COMMITS" | sed 's/^/- /')

## Notes
$(grep -A 100 '^## Notes' "$SESSION_FILE" 2>/dev/null | tail -n +2 || echo "- ")
ENDOFTEMPLATE

  mv "$TEMP_FILE" "$SESSION_FILE"
  echo "[SessionSave] Updated $SESSION_FILE" >&2
else
  # Create new session file
  cat > "$SESSION_FILE" << ENDOFTEMPLATE
# Session: $TODAY

**Project:** $PROJECT_NAME
**Branch:** $BRANCH
**Worktree:** $WORKTREE
**Last Updated:** $TIMESTAMP

---

## Modified Files (unstaged)
$(echo "$MODIFIED_FILES" | sed 's/^/- /')

## Staged Files
$(echo "$STAGED_FILES" | sed 's/^/- /')

## Recent Commits
$(echo "$RECENT_COMMITS" | sed 's/^/- /')

## Notes
- Session started
ENDOFTEMPLATE

  echo "[SessionSave] Created $SESSION_FILE" >&2
fi

# Pass through stdin (required for hooks)
cat
