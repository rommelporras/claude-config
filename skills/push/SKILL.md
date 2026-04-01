---
name: push
description: Validate and push the current branch to all configured remotes. Use when the user explicitly asks to push changes.
disable-model-invocation: true
allowed-tools: Bash, Read
---

Push the current branch to all configured remotes. Work through each step in order and stop immediately if a hard stop condition is met.

## Step 1 — Understand current state

Run in parallel:
- `git branch --show-current` — current branch name
- `git status --short` — check for uncommitted changes
- `git remote -v` — list all configured remotes (dedup: each remote appears twice in -v output, use unique names only)

Then run: `git log @{u}..HEAD --oneline 2>/dev/null` — show unpushed commits. If this fails (no upstream set), note that this is the first push for this branch.

If there are **no configured remotes**, stop here and say so.

If **already up to date** (zero unpushed commits AND upstream exists), report "already up to date" and stop — do not push unnecessarily.

If the **working tree is dirty** (uncommitted changes exist), warn the user but do not block.

## Step 2 — Check push constraints from CLAUDE.md

Read the project CLAUDE.md for any remote or branch push constraints. Look for:
- Protected remotes on specific branches (e.g. "main is protected on GitLab")
- Required push order across remotes
- Branches that should never be pushed directly

Note any constraints — apply them in Step 3.

## Step 3 — Push to each remote

**IMPORTANT:** `git push` is blocked by the global PreToolUse hook (`bash-write-protect.sh`).
You CANNOT run it directly — the hook will block it. Do NOT attempt to bypass the hook.

Instead, give the user the exact command to run via `!` prefix in the prompt.

For each remote (in order, `origin` first):

1. If a constraint from Step 2 blocks this remote, **skip it** and explain why
2. Otherwise, tell the user:

```
Run this to push:
! git push <remote> <branch>
```

Rules:
- **Never use `--force` or `-f`** unless the user explicitly requested it in their message
- Wait for the user to confirm the push completed before proceeding to the next remote

## Step 4 — Report results

After the user confirms the push, show a clear summary:

```
Push Results:
- Branch: <branch>
- <remote> (<url>): ✓ pushed  /  ✗ failed: <error>  /  ⊘ skipped: <reason>
- Commits pushed: <n>
```

## Hard stops

- **No remotes configured** — stop immediately.
- **Force push** — never add `--force` or `-f` without explicit user instruction.
- **CLAUDE.md hard block** — if CLAUDE.md explicitly forbids pushing the current branch anywhere, stop and explain.
