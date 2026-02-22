# claude-config

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Personal global [Claude Code](https://claude.ai/code) configuration — a single repo that applies consistent rules, hooks, and skills across every project automatically.

> Clone once. Symlink. Every project inherits the same guardrails.

## Table of Contents

- [Overview](#overview)
- [Contents](#contents)
- [New Machine Setup](#new-machine-setup)
- [How It Works](#how-it-works)
- [Permission Model](#permission-model)
- [Behavior Reference](#behavior-reference)
- [Project Sync Guide](#project-sync-guide)
- [Extending](#extending)
- [License](#license)

---

## Overview

Claude Code loads `~/.claude/` on every session. This repo lives at `~/personal/claude-config/` with `~/.claude/` pointing back into it via symlinks — so editing any file here takes effect immediately, in every project, with no reinstall.

**What it provides:**

- **Universal rules** — no AI attribution, no auto-commits, never start dev servers
- **Security hooks** — blocks secrets and destructive commands before they happen
- **Notifications** — alerts you (sound + OS popup) when Claude needs attention, across macOS, WSL2, and Linux
- **Global skills** — `/commit`, `/push`, and `/explain-code` work consistently across every repo
- **Global agents** — `code-reviewer` available in all projects, learns per-project conventions over time
- **Memory conventions** — clear guidance on what Claude should persist across sessions

---

## Contents

| Path | Purpose |
|------|---------|
| `CLAUDE.md` | Global instructions loaded at every session — universal rules, WSL2 environment, tooling preferences, memory conventions |
| `settings.json` | Model selection, enabled plugins, hook wiring (PreToolUse, Notification, Stop) |
| `hooks/protect-sensitive.sh` | Blocks Write/Edit to `.env`, credentials, and SSH key files by filename |
| `hooks/scan-secrets.sh` | Blocks Write/Edit if content contains hardcoded secrets (PEM keys, AWS/GitHub/Anthropic/OpenAI tokens) |
| `hooks/bash-write-protect.sh` | Blocks shell redirects to sensitive files and universally destructive commands |
| `hooks/notify.sh` | OS notification when Claude needs attention — macOS (`osascript`), WSL2 (`wsl-notify-send` → `notify-send` → PowerShell), Linux (`notify-send`) + terminal bell fallback |
| `skills/commit/` | Global `/commit` — conventional commits, secret scan, branch safety, no AI attribution |
| `skills/push/` | Global `/push` — auto-detects remotes, reads project CLAUDE.md push constraints, reports per-remote results |
| `skills/explain-code/` | Global `/explain-code` — structures explanations as analogy → ASCII diagram → walkthrough → gotcha |
| `agents/code-reviewer.md` | Global code reviewer — git diff analysis, 🔴/🟡/💡 feedback tiers, per-project memory via `memory: project` |

> **Skills priority:** Personal skills always win over project skills — a project-level skill with the same name cannot override one defined here. Only add skills that are 100% universal across all projects.

---

## New Machine Setup

```bash
git clone git@github.com:rommelporras/claude-config.git ~/personal/claude-config

ln -sf ~/personal/claude-config/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/personal/claude-config/settings.json ~/.claude/settings.json
ln -sf ~/personal/claude-config/hooks ~/.claude/hooks
ln -sf ~/personal/claude-config/skills ~/.claude/skills
ln -sf ~/personal/claude-config/agents ~/.claude/agents
```

Claude Code picks up `~/.claude/CLAUDE.md` automatically on the next session.

---

## How It Works

```
~/personal/claude-config/       ← versioned source of truth
├── CLAUDE.md
├── settings.json
├── hooks/
├── skills/
└── agents/

~/.claude/                      ← Claude Code config dir (all symlinks)
├── CLAUDE.md     ──────────→   ../personal/claude-config/CLAUDE.md
├── settings.json ──────────→   ../personal/claude-config/settings.json
├── hooks/        ──────────→   ../personal/claude-config/hooks/
├── skills/       ──────────→   ../personal/claude-config/skills/
└── agents/       ──────────→   ../personal/claude-config/agents/
```

Edit any file in this repo → change is immediately reflected in all Claude Code sessions. Commit to version it.

---

## Permission Model

`settings.json` sets `skipDangerousModePermissionPrompt: true` — Claude runs without per-action approval prompts. Three hook scripts act as the safety net:

| Hook | Trigger | What It Blocks |
|------|---------|----------------|
| `hooks/protect-sensitive.sh` | Write / Edit | `.env`, credentials, SSH keys — matched by filename |
| `hooks/scan-secrets.sh` | Write / Edit | Hardcoded secrets in content: PEM keys, AWS `AKIA*` keys, GitHub/Anthropic/OpenAI tokens |
| `hooks/bash-write-protect.sh` | Bash | Shell redirects to sensitive files; destructive commands: `rm -rf /`, fork bombs, `dd if=/dev`, `mkfs.*`, force push to `main`/`master` |

**Hook stacking:** Global hooks and project hooks both run — they don't replace each other. Add project-specific hooks in `.claude/hooks/` and they stack on top of these.

---

## Behavior Reference

| Feature | Priority Order | Effect |
|---------|---------------|--------|
| `CLAUDE.md` | Global → Project | Project instructions layer on top; project wins on conflicts |
| Skills (same name) | Personal → Project | Personal skill blocks any project-level override |
| Agents (same name) | Project → Personal | Project agent overrides the global default |
| Hooks | All run (stacked) | Global + project hooks both execute on every trigger |

---

## Project Sync Guide

When this global config is active, project-level commands with the same name as a global skill are **dead code** — the personal skill always wins regardless. Clean them up:

### 1. Remove dead commands

```bash
# Run inside any project repo — safe to delete, global skill is already active
rm .claude/commands/commit.md   # replaced by global /commit
rm .claude/commands/push.md     # replaced by global /push
```

### 2. Trim redundant rules from project CLAUDE.md

These are already enforced globally — remove them from individual project files:

| Rule | Where It Lives Globally |
|------|------------------------|
| No AI attribution in commits | `CLAUDE.md` → Universal Rules |
| No automatic git commits or pushes | `CLAUDE.md` → Universal Rules |
| Use `bun` for web projects | `CLAUDE.md` → Tooling Preferences |
| Use `uv` for Python projects | `CLAUDE.md` → Tooling Preferences |
| Conventional commit format | `CLAUDE.md` → Tooling Preferences |

Keep project-specific rules: branching model, tech stack decisions, domain constraints, and secrets layout.

### 3. Verify global skills respect project constraints

Global skills read the project CLAUDE.md for context. After cleanup, run a quick smoke test:

```bash
# On a protected branch — /commit should warn and ask for confirmation
/commit

# With multiple remotes — /push should push to each, skip any blocked ones
/push
```

---

## Extending

### Add a global skill

Skills in `skills/<name>/SKILL.md` are available in all projects as `/<name>`. Only add skills that are 100% universal — project skills cannot override personal ones.

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

Then commit and push so the skill is available on all machines:

```bash
cd ~/personal/claude-config
git add skills/my-skill
git commit -m "feat: add global /my-skill skill"
git push
```

### Add a global agent

Agents in `agents/<name>.md` are available as sub-agents in all projects. Use `memory: project` to let the agent build per-project knowledge over time.

```bash
cat > ~/personal/claude-config/agents/my-agent.md << 'EOF'
---
name: my-agent
description: What this agent does and when to invoke it
tools: Read, Grep, Glob, Bash
model: opus
memory: project
---

Agent instructions here.
EOF
```

Then commit and push:

```bash
cd ~/personal/claude-config
git add agents/my-agent.md
git commit -m "feat: add global my-agent agent"
git push
```

### Edit global instructions

```bash
# Edit CLAUDE.md — change takes effect immediately via symlink
vim ~/personal/claude-config/CLAUDE.md

# Version the change
cd ~/personal/claude-config
git add CLAUDE.md && git commit -m "chore: update global rules" && git push
```

---

## License

[MIT](LICENSE) — Copyright (c) 2026 Rommel Porras
