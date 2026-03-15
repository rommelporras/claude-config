# Performance & Model Routing

## Model Selection for Subagents

| Task Type | Model | Why |
|---|---|---|
| Exploration, file search | Haiku | Fast, cheap, sufficient for finding files |
| Simple single-file edits | Haiku | Clear instructions, minimal reasoning needed |
| Multi-file implementation | Sonnet | Best balance for coding tasks |
| PR reviews, code review | Sonnet | Good context understanding, catches nuance |
| Documentation updates | Haiku | Structure is simple, content is straightforward |
| Complex architecture | Opus | Deep reasoning, system-level thinking |
| Security analysis | Opus | Can't afford to miss vulnerabilities |
| Complex debugging | Opus | Needs to hold entire system in mind |

Default to **Sonnet** for coding tasks. Upgrade to **Opus** when: first attempt failed,
task spans 5+ files, architectural decisions needed, or security-critical code.

## Context Window Management

- Keep under 10 MCP servers enabled per session — tool definitions consume context.
- Disable unused MCPs per project. Configure globally, enable per-project.
- Use subagents to offload research — they get their own context window.
- Compact strategically at logical breakpoints, not when forced by limits.
- When approaching context limits: finish current task, compact, then continue.
