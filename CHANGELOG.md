# Changelog

All notable changes to this project will be documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.2](https://github.com/rommelporras/claude-config/releases/tag/v1.0.2) - 2026-03-14

Reorganises global config for better maintainability and adds settings-level attribution control.

### Changed
- Tooling preferences moved from CLAUDE.md to `rules/tooling.md` (user-level rule, loaded every session)
- Redundant Memory section removed from CLAUDE.md — now handled by built-in auto memory
- Compaction guidance added to CLAUDE.md to preserve critical context during long sessions
- Environment section expanded to support Aurora DX and Distrobox alongside WSL2
- Trunk-based branching default added to Universal Rules
- All `~/.claude/` config files now symlinked to repo (previously copied) — eliminates drift
- README updated with rules directory, symlink commands, architecture diagram, and migration table
- `.gitignore` updated to exclude `worktrees/`
- `attribution` setting added to `settings.json` — disables Co-Authored-By and PR attribution at the settings level
- `effortLevel: "high"` added to `settings.json`

## [v1.0.1](https://github.com/rommelporras/claude-config/releases/tag/v1.0.1) - 2026-02-23

Improves stop hook reliability and tightens the 1Password CLI access policy.

### Fixed
- Stop hook prompt restructured to place the JSON format constraint at the start rather than the end — Haiku weights early instructions more heavily, reducing intermittent "JSON validation failed" errors on long conversations

### Changed
- 1Password CLI policy tightened: `op` is now documented as completely unavailable in this terminal (not just requiring interactive auth); restriction extended to `kubectl create secret` and any command embedding `op` values

## [v1.0.0](https://github.com/rommelporras/claude-config/releases/tag/v1.0.0) - 2026-02-22

First stable release. All core security layers, global skills, and agent are in place and verified working.

### Added
- Global `/commit` skill — conventional commits, secret scan, branch safety check, no AI attribution
- Global `/push` skill — auto-detects remotes, respects project push constraints
- Global `/explain-code` skill — analogy → ASCII diagram → step-by-step walkthrough → gotcha
- `code-reviewer` agent with per-project memory via `memory: project`
- `notify.sh` hook — OS notification on Stop events (macOS, WSL2/Windows, Linux with terminal bell fallback)
- `protect-sensitive.sh` hook — blocks Write/Edit to `.env*`, `.pem`, credential files, SSH keys
- `scan-secrets.sh` hook — blocks Write/Edit if content contains PEM keys, AWS/GitHub/Anthropic/OpenAI tokens
- `bash-write-protect.sh` hook — blocks shell redirects to credential files and destructive commands
- `permissions.deny` rules — blocks credential reads (`~/.ssh`, `~/.aws`, `~/.gnupg`, `~/.config/gh`) and prevents Claude modifying its own settings
- Stop hook — Haiku model reviews conversation at end of session to catch incomplete tasks
- Context7 and Playwright MCP plugins enabled globally

### Fixed
- All three hook scripts had wrong JSON path (`tool_input.*` not top-level) — hooks were silently no-ops from initial commit until this fix
- Stop hook `JSON validation failed` error — switched from `"haiku"` shorthand to full model ID and added explicit JSON-only output instruction

### Changed
- Global CLAUDE.md expanded with project audit findings: no-destructive-ops rule, read-before-writing philosophy, Docker image pinning, test tooling preference, glab for GitLab ops, Python rule scoped to external dependencies
- README restructured for better flow: Architecture first, security layers clearly separated, sync block uses skills instead of raw git commands
