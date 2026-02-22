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
| `skills/commit/` | Global `/commit` skill — conventional commits, secret scan, branch safety, no AI attribution |
| `skills/push/` | Global `/push` skill — auto-detects remotes, respects CLAUDE.md push constraints |
| `agents/` | Global subagents available in all projects (currently empty) |

> **Skills note:** Personal skills take priority over project skills (personal > project).
> A project-level skill with the same name **cannot** override a skill defined here.
> Only add skills that are universal across all projects with no per-project variation.
> `/commit` and `/push` qualify: same safety rules and remote detection logic apply everywhere.

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

## Editing Global Instructions

```bash
# Edit CLAUDE.md (changes immediate via symlink, then commit)
vim ~/personal/claude-config/CLAUDE.md
cd ~/personal/claude-config && git add CLAUDE.md && git commit -m "chore: update global rules"
git push
```

## Syncing Existing Projects

When this global config is active, project-level commands with the same name as a global
skill are **dead code** — the personal skill always wins. Clean them up per project:

### Remove dead commands

```bash
# Run inside any project repo — safe to delete, global skill is already active
rm .claude/commands/commit.md   # replaced by global /commit
rm .claude/commands/push.md     # replaced by global /push
```

### Trim project CLAUDE.md

Remove rules already enforced globally — no need to repeat them per project:

| Already global | Where |
|---|---|
| No AI attribution in commits | `CLAUDE.md` → Universal Rules |
| No automatic git commits or pushes | `CLAUDE.md` → Universal Rules |
| Use `bun` for web projects | `CLAUDE.md` → Tooling Preferences |
| Use `uv` for Python projects | `CLAUDE.md` → Tooling Preferences |
| Conventional commit format | `CLAUDE.md` → Tooling Preferences |

Keep project-specific rules: branching model, tech stack, domain constraints, secrets layout.

### Verify global skills respect project constraints

Global skills read project CLAUDE.md for context. After cleanup, test:

```bash
# /commit: should block if on a protected branch (reads GitFlow rules from CLAUDE.md)
# /push: should skip protected remotes (reads push constraints from CLAUDE.md)
/commit   # on a protected branch → should warn and ask
/push     # with multiple remotes → should push to each, skip blocked ones
```

## Adding a Global Skill

Skills in `skills/<name>/SKILL.md` are available in all projects as `/<name>`.
Only add skills that are **100% universal** — project skills cannot override personal ones.

```bash
mkdir -p ~/personal/claude-config/skills/my-skill
cat > ~/personal/claude-config/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: What this skill does and when Claude should invoke it
disable-model-invocation: true
---

Skill instructions here.
EOF
```
