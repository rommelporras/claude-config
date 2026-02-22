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

## Personal Environment (WSL2)

- Shell: zsh.
- Windows Chrome for browser automation at the standard Windows path.
- 1Password CLI (`op`) is available but requires interactive auth — generate
  `op read` commands for the user to run, never run them autonomously.

## Engineering Philosophy

- **Evidence over assertions** — Never claim something works without showing proof.
  Don't say "tests pass" or "the fix works" — show the output.
- **Systematic over ad-hoc** — Understand before acting. Investigate root causes,
  never guess and re-guess. If stuck, step back — don't brute-force.
- **Minimal, focused changes** — Solve exactly what was asked. No gold-plating,
  no unrequested refactors, no speculative abstractions.

## Tooling Preferences

- **Web projects:** use `bun`, never `npm` or `yarn`.
- **Python projects:** use `uv` (never `pip3` or `pip`).
- **TypeScript:** strict mode only — no `any`, no `// @ts-ignore`.
- **Documentation:** check Context7 (MCP) before WebFetch for library docs.
- **Commits:** use conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `infra:`).
