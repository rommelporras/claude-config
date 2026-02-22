# claude-config

Personal global Claude Code configuration — applies to all projects automatically.

## What's Here

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Global instructions: universal rules, WSL2 env, code preferences |
| `settings.json` | Model, plugins, global hooks |
| `hooks/protect-sensitive.sh` | Blocks writes to `.env`, credentials, SSH keys on every project (Write/Edit) |
| `hooks/bash-write-protect.sh` | Blocks Bash shell redirects (`>`, `>>`, `tee`) to sensitive files |
| `hooks/scan-secrets.sh` | Blocks Write/Edit if content contains secret patterns (keys, tokens, PEM) |
| `skills/commit/` | Global `/commit` skill — conventional commits, secret scan, no AI attribution |
| `agents/` | Global subagents available in all projects (currently empty) |

> **Skills note:** Personal skills take priority over project skills (personal > project).
> A project-level skill with the same name **cannot** override a skill defined here.
> Only add skills that are universal across all projects with no per-project variation.
> `/commit` qualifies: all projects use conventional commits and the same safety rules.

## New Machine Setup

Clone and symlink:

```bash
git clone git@github.com:rommelporras/claude-config.git ~/personal/claude-config

ln -sf ~/personal/claude-config/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/personal/claude-config/settings.json ~/.claude/settings.json
mkdir -p ~/.claude/hooks
ln -sf ~/personal/claude-config/hooks/protect-sensitive.sh ~/.claude/hooks/protect-sensitive.sh
ln -sf ~/personal/claude-config/hooks/bash-write-protect.sh ~/.claude/hooks/bash-write-protect.sh
ln -sf ~/personal/claude-config/hooks/scan-secrets.sh ~/.claude/hooks/scan-secrets.sh
ln -sf ~/personal/claude-config/skills ~/.claude/skills
ln -sf ~/personal/claude-config/agents ~/.claude/agents
```

Claude Code picks up `~/.claude/CLAUDE.md` automatically on next session.

## How It Works

Files live here. `~/.claude/` has symlinks pointing into this repo.
Editing any file = immediately reflected. Commit to version it.

## Priority Reference

| Feature | Priority order | Effect |
|---------|---------------|--------|
| CLAUDE.md | Global → Project (project wins) | Project instructions add on top and override conflicts |
| Skills (same name) | Personal → Project (personal wins) | Personal skill blocks project override — use carefully |
| Agents (same name) | Project → Personal (project wins) | Project can override a global agent |
| Hooks | All run (stacked) | Global + project hooks both execute |

## Adding a Global Agent

```bash
cat > ~/personal/claude-config/agents/my-agent.md << 'EOF'
---
name: my-agent
description: What this agent does and when to use it
---

Agent instructions here.
EOF

cd ~/personal/claude-config
git add agents/my-agent.md
git commit -m "feat: add my-agent global agent"
git push
```

## Editing Global Instructions

```bash
# Edit CLAUDE.md (changes immediate via symlink, then commit)
vim ~/personal/claude-config/CLAUDE.md
cd ~/personal/claude-config && git add CLAUDE.md && git commit -m "chore: update global rules"
git push
```
