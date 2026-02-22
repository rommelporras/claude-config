# claude-config

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Personal global [Claude Code](https://claude.ai/code) configuration — one repo, every project protected.

- **Universal rules** — no AI attribution, no auto-commits, never start dev servers, no destructive ops without confirmation
- **Security** — blocks credential reads, hardcoded secrets, and destructive commands via hooks; Claude asks before any destructive operation
- **Notifications** — OS popup + sound when Claude needs attention, on macOS, WSL2, and Linux
- **Global skills** — `/commit`, `/push`, and `/explain-code` available in every repo
- **Global agents** — `code-reviewer` with per-project memory, available in all projects

## Table of Contents

- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [What's Included](#whats-included)
- [Security](#security)
- [Extending](#extending)
- [Migrating Existing Projects](#migrating-existing-projects)
- [License](#license)

---

## Architecture

Claude Code loads `~/.claude/` on every session. This repo lives at `~/personal/claude-config/` with `~/.claude/` pointing back to it entirely via symlinks — edit any file here and the change is live immediately in every project, with no reinstall.

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

**When global and project-level configs conflict:**

| Component | Who wins | Behaviour |
|-----------|----------|-----------|
| `CLAUDE.md` | Project over Global | Project instructions layer on top; project wins conflicts |
| Skills (same name) | Personal over Project | Personal skill silently blocks any project-level override |
| Agents (same name) | Project over Personal | Project agent overrides the global default |
| Hooks | Both run | Global + project hooks stack — neither replaces the other |

---

## Quick Start

```bash
git clone git@github.com:rommelporras/claude-config.git ~/personal/claude-config

ln -sf ~/personal/claude-config/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/personal/claude-config/settings.json ~/.claude/settings.json
ln -sf ~/personal/claude-config/hooks ~/.claude/hooks
ln -sf ~/personal/claude-config/skills ~/.claude/skills
ln -sf ~/personal/claude-config/agents ~/.claude/agents
```

Restart Claude Code. Every project now inherits these rules automatically.

---

## What's Included

| Path | Purpose |
|------|---------|
| `CLAUDE.md` | Global instructions — universal rules, WSL2 environment, tooling preferences, memory conventions |
| `settings.json` | Model, plugins, permission deny rules, hook wiring |
| `hooks/protect-sensitive.sh` | Blocks Write/Edit to `.env*`, `.pem`, credential files, SSH keys — matched by filename |
| `hooks/scan-secrets.sh` | Blocks Write/Edit if content contains hardcoded secrets (PEM keys, AWS/GitHub/Anthropic/OpenAI tokens) |
| `hooks/bash-write-protect.sh` | Blocks shell redirects to sensitive files and universally destructive commands |
| `hooks/notify.sh` | OS notification when Claude needs attention — macOS, WSL2, and Linux with terminal bell fallback |
| `skills/commit/` | `/commit` — conventional commits, secret scan, branch safety, no AI attribution |
| `skills/push/` | `/push` — auto-detects remotes, respects project push constraints |
| `skills/explain-code/` | `/explain-code` — analogy → ASCII diagram → walkthrough → gotcha |
| `agents/code-reviewer.md` | Code reviewer — 🔴/🟡/💡 feedback tiers, per-project memory via `memory: project` |

---

## Security

`settings.json` sets `skipDangerousModePermissionPrompt: true` so Claude runs without per-action approval prompts. Two protection layers make this safe — and a third is available per project for higher-risk work.

### Layer 1 — Permission deny rules

Configured in `settings.json` under `permissions.deny` and evaluated by Claude Code before any tool executes. Nothing reaches the hooks if a deny rule matches first.

The settings file rules close a specific attack path: a prompt injection inside user-controlled data (a database record, an API response) cannot modify permission rules to unlock access to credentials.

| Rule | What it blocks |
|------|----------------|
| `Read(~/.ssh/**)` | SSH private keys |
| `Read(~/.aws/**)` | AWS credentials |
| `Read(~/.gnupg/**)` | GPG private keys |
| `Read(~/.config/gh/**)` | GitHub CLI auth tokens |
| `Edit/Write(~/.claude/settings.json)` | Claude modifying its own global config |
| `Edit/Write(./.claude/settings.json)` | Claude modifying project config |
| `Edit/Write(./.claude/settings.local.json)` | Claude modifying local project overrides |

### Layer 2 — Hook scripts

Run via `PreToolUse` hooks before each tool call. Hooks stack — project-level hooks in `.claude/hooks/` run alongside these, not instead of them.

| Hook | Fires on | What it blocks |
|------|----------|----------------|
| `protect-sensitive.sh` | Write / Edit | Files matching `.env*`, `.pem`, `credentials.json`, `id_rsa`, `id_ed25519`, `id_ecdsa` |
| `scan-secrets.sh` | Write / Edit | Content containing PEM keys, AWS `AKIA*` keys, GitHub/Anthropic/OpenAI tokens |
| `bash-write-protect.sh` | Bash | Redirects to sensitive files; `rm -rf /`, fork bombs, `dd if=/dev`, `mkfs.*`, force push to `main`/`master` |

### Layer 3 — Per-project sandboxing (optional)

OS-level enforcement so even a successful prompt injection cannot exfiltrate files or reach unauthorized network hosts. Stays per-project because `allowedDomains` and `excludedCommands` differ per stack.

**Prerequisites (Linux / WSL2):**

```bash
sudo apt-get install bubblewrap socat
```

**Add to your project's `.claude/settings.json`:**

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "allowUnsandboxedCommands": false,
    "excludedCommands": ["docker"],
    "network": {
      "allowedDomains": [
        "github.com",
        "*.npmjs.org",
        "registry.npmjs.org",
        "pypi.org",
        "files.pythonhosted.org"
      ]
    }
  }
}
```

The domain list builds naturally — the first time Claude needs a domain not in the list it prompts you to allow it, and granting adds it permanently. `docker` is excluded because it requires host access incompatible with the sandbox.

---

## Extending

> Only add skills here that are universal across **all** your projects — personal skills silently block any project-level skill with the same name.

### Add a skill

Create `skills/<name>/SKILL.md` with this frontmatter:

```yaml
---
name: my-skill
description: What this skill does and when to invoke it
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob
---

Skill instructions here.
```

The skill is immediately available as `/<name>` in every project.

### Add an agent

Create `agents/<name>.md` with this frontmatter:

```yaml
---
name: my-agent
description: What this agent does and when to invoke it
tools: Read, Grep, Glob, Bash
model: opus
memory: project
---

Agent instructions here.
```

`memory: project` gives the agent a per-project memory file at `.claude/agent-memory/<name>/MEMORY.md` that persists across sessions.

### Edit global rules

Edit `CLAUDE.md` directly — the symlink means it takes effect immediately. No reinstall needed.

---

After any change, commit and push to sync across all your machines:

```bash
cd ~/personal/claude-config
/commit
/push
```

---

## Migrating Existing Projects

When this global config is active, project-level skills with the same name as a global skill are **dead code** — the personal skill always wins. Clean them up after setup:

**Remove shadowed skill files:**

```bash
rm .claude/commands/commit.md   # replaced by global /commit
rm .claude/commands/push.md     # replaced by global /push
```

**Remove rules already enforced globally** from project `CLAUDE.md` files:

| Rule | Lives in |
|------|----------|
| No AI attribution in commits | `CLAUDE.md` → Universal Rules |
| No automatic git commits or pushes | `CLAUDE.md` → Universal Rules |
| Use `bun` for web projects | `CLAUDE.md` → Tooling Preferences |
| Use `uv` for Python projects with external dependencies | `CLAUDE.md` → Tooling Preferences |
| Conventional commit format | `CLAUDE.md` → Tooling Preferences |

Keep project-specific rules: branching model, tech stack decisions, domain constraints, secrets layout.

**Smoke test after cleanup** — run these inside a project, not inside this repo:

```bash
# On a protected branch — /commit should warn before proceeding
/commit

# With multiple remotes — /push should push to each and report per-remote results
/push
```

---

## License

[MIT](LICENSE) — Copyright (c) 2026 Rommel Porras
