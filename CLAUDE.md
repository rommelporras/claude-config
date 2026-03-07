# CLAUDE.md

Personal global instructions — applies to all projects.
Project CLAUDE.md files add project-specific context on top of this.

## Universal Rules

- **NO AI attribution** — no "Generated with Claude Code", "Co-Authored-By: Claude",
  or any AI-related attribution in commits, PRs, or code comments.
- **NO automatic git commits or pushes** — only commit when explicitly asked via
  `/commit`, `/release`, or direct user instruction.
- **Security review before every commit** — scan all changed files for leaked
  secrets before staging. Use secret manager references only, never hardcoded values.
- **Never run dev servers** — never start `bun run dev`, `uvicorn`, or similar
  background processes. Instruct the user to run them.
- **No destructive operations without confirmation** — `rm -rf`, force pushes,
  `kubectl delete`, `helm uninstall`, or anything that destroys data requires
  explicit user confirmation before running.
- **Branching default: trunk-based** — commit directly to `main` unless the project
  CLAUDE.md specifies a different strategy (e.g. GitFlow with `develop`).

## Environment

Environment is auto-detected. Key constraints per platform:

- **Aurora DX** (immutable Fedora): No `apt-get`, no `chsh`. Use `rpm-ostree` or `brew`.
  Shell is zsh via Ptyxis custom command. 1Password SSH Agent at `~/.1password/agent.sock`.
- **WSL2**: No `op` access in this terminal. Windows Chrome for browser automation.
- **Distrobox**: No `op` access — use `distrobox-host-exec op` if needed.
  `$HOME` is container-local, not the host home.

All platforms:
- Self-hosted GitLab is the primary remote; use `glab` CLI for GitLab operations.
- Work projects may use GitHub instead.
- **Never run `op` commands** — generate them and ask the user to run manually.

## Engineering Philosophy

- **Evidence over assertions** — Never claim something works without showing proof.
  Don't say "tests pass" or "the fix works" — show the output.
- **Read before writing** — Understand existing patterns in the codebase before
  modifying or adding code.
- **Systematic over ad-hoc** — Understand root cause before acting. When stuck,
  step back and rethink — never retry the same failing approach with minor variations.
- **Minimal, focused changes** — Solve exactly what was asked. No gold-plating,
  no unrequested refactors, no speculative abstractions.

## Tooling Preferences

- **Web projects:** use `bun`, never `npm` or `yarn`.
- **Python projects with external dependencies:** use `uv`, never `pip3` or `pip`.
- **TypeScript:** strict mode only — no `any`, no `// @ts-ignore`.
- **Tests:** Vitest for unit/integration, Playwright for E2E.
- **Docker:** pin image versions in all Dockerfiles and docker-compose files — never use `latest`.
- **Documentation:** check Context7 (MCP) before WebFetch for library docs.
- **Commits:** use conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `infra:`).

## Memory

Claude Code auto-saves notes per project. Path is auto-generated from project location.

**Save:** Stable patterns, key file paths, user preferences, recurring problem solutions.
**Skip:** Session-specific context, speculative conclusions, anything already in project CLAUDE.md.
**Trim:** Remove entries that turn out wrong or are superseded by newer findings.
