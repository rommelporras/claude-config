#!/usr/bin/env bash
# PostToolUse/Edit hook: auto-format JS/TS/Python files after edits
# Detects Biome, Prettier, or Ruff and formats accordingly

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null || echo "")

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  echo "$INPUT"
  exit 0
fi

EXT="${FILE_PATH##*.}"

format_js_ts() {
  local dir
  dir=$(dirname "$FILE_PATH")

  # Walk up to find project root with formatter config
  while [ "$dir" != "/" ]; do
    # Check for Biome
    if [ -f "$dir/biome.json" ] || [ -f "$dir/biome.jsonc" ]; then
      if command -v biome &>/dev/null; then
        biome check --write "$FILE_PATH" 2>/dev/null || true
      elif [ -x "$dir/node_modules/.bin/biome" ]; then
        "$dir/node_modules/.bin/biome" check --write "$FILE_PATH" 2>/dev/null || true
      fi
      return
    fi

    # Check for Prettier
    if [ -f "$dir/.prettierrc" ] || [ -f "$dir/.prettierrc.json" ] || [ -f "$dir/.prettierrc.js" ] || [ -f "$dir/prettier.config.js" ] || [ -f "$dir/prettier.config.mjs" ]; then
      if command -v prettier &>/dev/null; then
        prettier --write "$FILE_PATH" 2>/dev/null || true
      elif [ -x "$dir/node_modules/.bin/prettier" ]; then
        "$dir/node_modules/.bin/prettier" --write "$FILE_PATH" 2>/dev/null || true
      fi
      return
    fi

    dir=$(dirname "$dir")
  done
}

format_python() {
  if command -v ruff &>/dev/null; then
    ruff format "$FILE_PATH" 2>/dev/null || true
  fi
}

case "$EXT" in
  ts|tsx|js|jsx|json)
    format_js_ts
    ;;
  py)
    format_python
    ;;
esac

echo "$INPUT"
