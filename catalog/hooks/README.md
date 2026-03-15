# Available Hooks

These hooks are NOT installed globally. Add them to a project's `.claude/settings.json` when needed.

## Web/Application Development

| Hook | Trigger | Use when |
|------|---------|----------|
| `typecheck.sh` | PostToolUse/Edit | TypeScript projects - runs tsc after each .ts/.tsx edit |
| `post-edit-format.sh` | PostToolUse/Edit | JS/TS/Python projects with Biome, Prettier, or Ruff |
| `console-log-check.sh` | Stop | JS/TS projects - warns about console.log before commit |
| `tmux-reminder.sh` | PreToolUse/Bash | Long-running commands outside tmux |

## Installation

Add to your project's `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/personal/claude-config/catalog/hooks/post-edit-format.sh"
          },
          {
            "type": "command",
            "command": "$HOME/personal/claude-config/catalog/hooks/typecheck.sh"
          }
        ]
      }
    ]
  }
}
```
