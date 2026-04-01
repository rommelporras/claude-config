#!/usr/bin/env bash
# PreToolUse hook — blocks Bash commands that write to sensitive files or run
# universally destructive operations.
# Fires on the Bash tool; companion to protect-sensitive.sh (Write/Edit).
#
# Exit 2 = block the tool call and show error to user.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# =============================================================================
# SENSITIVE FILE WRITES — block redirects to credential files
# =============================================================================

PROTECTED=(
  ".env"
  ".env.local"
  ".env.production"
  ".env.development"
  ".env.staging"
  ".env.test"
  ".pem"
  "credentials.json"
  ".credentials.json"
  "id_rsa"
  "id_ed25519"
  "id_ecdsa"
)

for pattern in "${PROTECTED[@]}"; do
  if echo "$COMMAND" | grep -qE "(>{1,2}|tee(\s+-a)?)\s+['\"]?([^'\" ]*\/)?${pattern}['\"]?(\s*$|\s*[|&;])"; then
    echo "BLOCKED: Command writes to sensitive file matching '$pattern'." >&2
    echo "Edit this file manually in your terminal." >&2
    exit 2
  fi
done

# =============================================================================
# DESTRUCTIVE OPERATIONS — block universally dangerous commands
# =============================================================================

DANGEROUS=(
  "rm -rf /"        # root filesystem destruction (also matches rm -rf /any/abs/path)
  "rm -rf /*"       # root wildcard destruction
  "rm -rf ~"        # home directory destruction
  "> /dev/sd"       # direct disk device writes
  "> /dev/nvme"     # direct NVMe device writes
  "mkfs."           # filesystem format
  ":(){:|:&};:"     # fork bomb
  "dd if=/dev"      # disk reads piped to destructive ops
  "chmod -R 777 /"  # strips all protections from root tree
)

for pattern in "${DANGEROUS[@]}"; do
  if [[ "$COMMAND" == *"$pattern"* ]]; then
    echo "BLOCKED: Destructive command pattern detected: '$pattern'" >&2
    echo "Run this manually in your terminal if you are certain." >&2
    exit 2
  fi
done

# =============================================================================
# GIT PUSH — always blocked, no bypass
# =============================================================================
# Claude must NEVER push directly. The /push skill tells the user to run
# `! git push origin main` themselves. Lock files do NOT bypass this.
# Force push is doubly blocked (matched by both checks).

if echo "$COMMAND" | grep -qE '\bgit\s+push\b'; then
  echo "BLOCKED: git push is not allowed." >&2
  echo "   Use /push (which gives you the command to run yourself)." >&2
  echo "   Or run directly: ! git push origin main" >&2
  exit 2
fi

exit 0
