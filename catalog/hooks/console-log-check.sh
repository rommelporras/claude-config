#!/usr/bin/env bash
# Stop hook: check for console.log in modified JS/TS files
# Warns about debug statements that should be removed before committing

set -euo pipefail

INPUT=$(cat)

# Only run in git repos
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "$INPUT"
  exit 0
fi

# Get modified JS/TS files (exclude tests, configs, scripts)
FILES=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(ts|tsx|js|jsx)$' | grep -vE '(\.test\.|\.spec\.|\.config\.|scripts/|__tests__/|__mocks__/)' || true)

if [ -z "$FILES" ]; then
  echo "$INPUT"
  exit 0
fi

HAS_CONSOLE=false
while IFS= read -r file; do
  if [ -f "$file" ] && grep -q 'console\.log' "$file"; then
    echo "[Hook] WARNING: console.log found in $file" >&2
    HAS_CONSOLE=true
  fi
done <<< "$FILES"

if [ "$HAS_CONSOLE" = true ]; then
  echo "[Hook] Remove console.log statements before committing" >&2
fi

echo "$INPUT"
