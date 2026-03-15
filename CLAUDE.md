# CLAUDE.md

Personal global instructions — applies to all projects.
Project CLAUDE.md files add project-specific context on top of this.

## Universal Rules

- **NO AI attribution** — no "Co-Authored-By: Claude", "Generated with Claude Code",
  "AI-assisted", or any AI reference in commits, PRs, code comments, or docs.
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
  Don't say "tests pass" or "the fix works" — run the command and show the output.
  No "should work", "probably fixed", or satisfaction before verification.
- **Read before writing** — Understand existing patterns in the codebase before
  modifying or adding code.
- **Systematic over ad-hoc** — Understand root cause before acting. When stuck,
  step back and rethink — never retry the same failing approach with minor variations.
- **Minimal, focused changes** — Solve exactly what was asked. No gold-plating,
  no unrequested refactors, no speculative abstractions.

## Working Strategy

### Plan Before Building

- For any non-trivial task (3+ steps or architectural decisions), enter plan mode
  and write a plan before touching code. Write detailed specs upfront to reduce ambiguity.
- If an approach goes sideways, **STOP and re-plan immediately** — don't keep pushing.
  Two failures on the same approach = mandatory re-plan.
- For creative work (new features, components, behavior changes), explore intent and
  design before implementation. Propose 2-3 approaches with trade-offs. Get user
  approval before writing code.

### Test-Driven Development

- Write the failing test first. Watch it fail. Write minimal code to pass. Verify green.
- No production code without a failing test first. Code before test? Delete it, start over.
- Bug fixes require a regression test that reproduces the bug before writing the fix.
- Tests use real code — mocks only when unavoidable (external APIs, etc.).

### Systematic Debugging

- No fixes without root cause investigation first. Read error messages completely.
  Reproduce consistently. Check recent changes. Trace data flow.
- One hypothesis at a time. Make the smallest possible change to test it.
  Don't fix multiple things at once.
- If 3+ fix attempts fail, STOP — it's likely an architectural problem, not a bug.
  Discuss with the user before attempting more fixes.

### Agent Orchestration

Use agents proactively — don't wait for the user to ask:

| Trigger | Agent | Model |
|---|---|---|
| Complex feature request | `planner` | Opus |
| Architectural decision | `architect` | Opus |
| Code just written/modified | `code-reviewer` | Opus |
| Documentation updates | `doc-updater` | Haiku |

- Use subagents to keep main context window clean. Offload research, exploration,
  and parallel analysis to subagents.
- One task per subagent for focused execution.
- Launch multiple agents in parallel for independent operations.
- Never trust subagent success reports — verify changes independently via diff.

### Autonomous Bug Fixing

- When given a bug report, just fix it. Don't ask for hand-holding.
- Point at logs, errors, failing tests — then resolve them.
- Zero context switching required from the user.

## Context Management

When compacting, always preserve: the full list of modified files, test commands
that were used, and any architectural decisions made during the session.
