#!/usr/bin/env bash
# PreToolUse hook — blocks Bash commands that write to sensitive files.
# Fires on the Bash tool; companion to protect-sensitive.sh which covers Write/Edit.
#
# Exit 2 = block the tool call and show error to user.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.command // ""')

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

PROTECTED=(
  ".env"
  ".env.local"
  ".env.production"
  "credentials.json"
  ".credentials.json"
  "id_rsa"
  "id_ed25519"
  "id_ecdsa"
)

for pattern in "${PROTECTED[@]}"; do
  # Match: echo ... > .env | echo ... >> .env | tee .env | tee -a .env
  # Handles bare filenames and path-prefixed filenames (e.g. /path/to/.env)
  if echo "$COMMAND" | grep -qE "(>{1,2}|tee(\s+-a)?)\s+['\"]?([^'\" ]*\/)?${pattern}['\"]?(\s*$|\s*[|&;])"; then
    echo "BLOCKED: Command writes to sensitive file matching '$pattern'." >&2
    echo "Edit this file manually in your terminal." >&2
    exit 2
  fi
done

exit 0
