# Available Agents

These agents are NOT installed globally. Copy them into a project's `.claude/agents/` directory when needed.

## Web/Application Development

| Agent | Use when | Copy command |
|-------|----------|-------------|
| `security-reviewer.md` | Code handles user input, auth, API endpoints, sensitive data | `cp ~/personal/claude-config/catalog/agents/security-reviewer.md .claude/agents/` |
| `build-resolver.md` | Build fails or type errors occur (TypeScript/JS projects) | `cp ~/personal/claude-config/catalog/agents/build-resolver.md .claude/agents/` |
| `tdd-guide.md` | Implementing features or fixing bugs with TDD (Vitest/Playwright) | `cp ~/personal/claude-config/catalog/agents/tdd-guide.md .claude/agents/` |
| `refactor-cleaner.md` | Dead code cleanup, unused deps (JS/TS projects with knip/depcheck) | `cp ~/personal/claude-config/catalog/agents/refactor-cleaner.md .claude/agents/` |
