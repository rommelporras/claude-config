#!/usr/bin/env bash
# PostToolUse/Edit hook: run tsc --noEmit after editing .ts/.tsx files
# Only shows errors related to the edited file, not the entire project

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null || echo "")

# Only run for TypeScript files
if [[ ! "$FILE_PATH" =~ \.(ts|tsx)$ ]]; then
  echo "$INPUT"
  exit 0
fi

if [ ! -f "$FILE_PATH" ]; then
  echo "$INPUT"
  exit 0
fi

# Find nearest tsconfig.json by walking up
DIR=$(dirname "$(realpath "$FILE_PATH")")
TSCONFIG_DIR=""
DEPTH=0

while [ "$DIR" != "/" ] && [ $DEPTH -lt 20 ]; do
  if [ -f "$DIR/tsconfig.json" ]; then
    TSCONFIG_DIR="$DIR"
    break
  fi
  DIR=$(dirname "$DIR")
  DEPTH=$((DEPTH + 1))
done

if [ -z "$TSCONFIG_DIR" ]; then
  echo "$INPUT"
  exit 0
fi

# Run tsc and filter to only the edited file's errors
TSC_BIN="$TSCONFIG_DIR/node_modules/.bin/tsc"
if [ ! -x "$TSC_BIN" ]; then
  TSC_BIN="npx tsc"
fi

ERRORS=$($TSC_BIN --noEmit --pretty false 2>&1 || true)

# Filter to lines mentioning the edited file
BASENAME=$(basename "$FILE_PATH")
RELEVANT=$(echo "$ERRORS" | grep -F "$BASENAME" | head -10 || true)

if [ -n "$RELEVANT" ]; then
  echo "[Hook] TypeScript errors in $BASENAME:" >&2
  echo "$RELEVANT" >&2
fi

echo "$INPUT"
