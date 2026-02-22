# Create Release

Tag, update CHANGELOG, push, and create GitHub release.

## Usage

```
/release                      → Auto-determine version from commits
/release v1.0.0               → Explicit version, auto-generate title
/release v1.0.0 "Title Here"  → Explicit version AND title
```

## Instructions

1. **Check Current State**

   ```bash
   git branch --show-current
   git status
   git log --oneline -10
   git describe --tags --abbrev=0 2>/dev/null || echo "No tags yet"
   ```

   - **Must be on `main`** — abort if on any other branch
   - Working tree **must** be clean — abort if dirty

2. **Remote Tag Collision Check**

   Fetch latest tags and verify the target version doesn't already exist:
   ```bash
   git fetch origin --tags
   git tag -l "v<VERSION>"
   ```

   If the tag already exists:
   - **ABORT** immediately
   - Show: `"Error: Tag v<VERSION> already exists. Check https://github.com/rommelporras/claude-config/releases"`
   - Suggest the next available version

3. **Determine Version and Title**

   The full release title is always: `v<VERSION> - <Short Title>`
   (regular hyphen `-`, NOT em dash `—`).

   **If user provided version and title** (e.g., `/release v1.0.0 "Initial Release"`):
   - Use the provided version and title

   **If user provided version only** (e.g., `/release v1.0.0`):
   - Use the provided version
   - Auto-generate `<Short Title>` from commit analysis

   **If no version provided** (`/release`):
   - Find the last tag
   - Analyze commits since last tag
   - Auto-bump based on commit types:
     - `feat:` → **minor** bump (v1.0.0 → v1.1.0)
     - `fix:`, `docs:`, `chore:` only → **patch** bump (v1.0.0 → v1.0.1)
     - `BREAKING CHANGE` in commit body → **major** bump (v1.0.0 → v2.0.0)
   - Auto-generate `<Short Title>` from commit analysis

   **First release** (no previous tags):
   - Default to `v1.0.0` unless user specifies

4. **Analyze Changes for Release Notes**

   Get commits since last tag (or all commits for first release):
   ```bash
   git log <last-tag>..HEAD --oneline   # or git log --oneline for first release
   ```

   Group by category and understand the PURPOSE, not just list commits:
   - Security
   - Features
   - Bug fixes
   - Configuration / Settings
   - Documentation
   - Chores

5. **Write Release Notes**

   **Tag annotation format:**
   ```
   v<VERSION> - <Short Title>

   <One sentence summary of this release>

   <Category 1>:
   - Specific item
   - Specific item

   <Category 2>:
   - Specific item
   ```

   **GitHub release format (markdown):**
   ```markdown
   ## Summary
   <One paragraph describing what this release contains>

   ## What's Included

   ### <Category 1>
   - Item 1
   - Item 2

   ### <Category 2>
   - Item 1
   - Item 2

   ## Commits
   - `abc1234` commit message 1
   - `def5678` commit message 2
   ```

6. **Show Release Plan and Confirm**

   Present the full plan and **wait for user confirmation**:
   ```
   Release Plan:
   - Version: v<VERSION>
   - Title: "v<VERSION> - <Short Title>"
   - Commits: <N> (since <last-tag> or "all commits" for first release)
   - Will push to: origin (GitHub)
   - Will create: Annotated tag v<VERSION>
   - Will create: GitHub release
   - Will update: CHANGELOG.md

   Pre-release checks:
   - Remote tag collision: ✓ No conflict
   - Branch: ✓ on main
   - Working tree: ✓ clean

   Proceed with release? (waiting for confirmation)
   ```

   **Do NOT proceed until user confirms.**

7. **Update CHANGELOG.md**

   First, check if CHANGELOG.md already has an entry for this version:
   ```bash
   grep -q "## \[v<VERSION>\]" CHANGELOG.md 2>/dev/null
   ```
   If the entry already exists, **skip this step entirely** — do not duplicate it.

   If `CHANGELOG.md` does not exist, create it with a standard header first:
   ```markdown
   # Changelog

   All notable changes to this project will be documented here.

   Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
   Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
   ```

   Prepend a new entry **after the header lines** but **before the first `## [v` entry**:
   ```markdown
   ## [v<VERSION>](https://github.com/rommelporras/claude-config/releases/tag/v<VERSION>) - <YYYY-MM-DD>

   <One sentence summary of this release>

   ### Added
   - New features from `feat:` commits

   ### Fixed
   - Bug fixes from `fix:` commits

   ### Changed
   - Changes from `docs:`, `chore:`, `security:`, `refactor:` commits

   ### Removed
   - Anything removed (if applicable)
   ```

   Rules:
   - Only include sections (Added/Fixed/Changed/Removed) that have items
   - Date is today's date in YYYY-MM-DD format
   - Descriptions should be human-readable, not raw commit messages

   Commit the changelog:
   ```bash
   git add CHANGELOG.md
   git commit -m "docs: update CHANGELOG for v<VERSION>"
   ```

8. **Execute Release**

   ```bash
   # Create annotated tag
   git tag -a v<VERSION> -m "<tag annotation>"

   # Push commits + tag
   git push origin main
   git push origin v<VERSION>

   # Create GitHub release
   gh release create v<VERSION> \
     --repo rommelporras/claude-config \
     --title "v<VERSION> - <Short Title>" \
     --notes "<release notes markdown>"
   ```

9. **Report Results**

   ```
   Release Complete:
   - Version: v<VERSION>
   - Tag: v<VERSION> on main
   - CHANGELOG.md: ✓ updated
   - origin (GitHub): ✓ main + tag pushed
   - GitHub release: <URL>
   ```

## Example — v1.0.0

**Tag annotation:**
```
v1.0.0 - Initial Stable Release

All core security layers, global skills, and agent in place and verified working.

Security:
- permissions.deny rules block credential reads and settings manipulation
- protect-sensitive.sh, scan-secrets.sh, bash-write-protect.sh hooks verified

Skills & Agents:
- Global /commit, /push, /explain-code skills available in every project
- code-reviewer agent with per-project memory

Bug Fixes:
- Corrected tool_input JSON path in all three hook scripts (were silent no-ops)
- Fixed stop hook JSON validation error with full model ID
```

**GitHub release notes:**
```markdown
## Summary

First stable release of claude-config — a global Claude Code configuration that
protects every project with layered security, provides universal skills, and
enforces consistent engineering practices across all repos.

## What's Included

### Security
- `permissions.deny` rules block credential reads (`~/.ssh`, `~/.aws`, `~/.gnupg`)
  and prevent Claude from modifying its own settings (closes prompt injection path)
- `protect-sensitive.sh` — blocks writes to `.env*`, `.pem`, SSH key files
- `scan-secrets.sh` — blocks hardcoded PEM keys, AWS/GitHub/Anthropic/OpenAI tokens
- `bash-write-protect.sh` — blocks destructive shell commands and credential redirects

### Global Skills
- `/commit` — conventional commits with secret scan, branch safety, no AI attribution
- `/push` — auto-detects remotes, respects project push constraints
- `/explain-code` — analogy → ASCII diagram → walkthrough → gotcha

### Agents
- `code-reviewer` — structured feedback with per-project memory

### Bug Fixes
- All three hook scripts had incorrect JSON path (`tool_input.*`) — were silent no-ops from initial commit
- Stop hook `JSON validation failed` — full Haiku model ID + JSON-only output instruction

## Commits
- `4b65b56` fix: use full haiku model ID and require JSON-only output in stop hook
- `92300af` docs: improve global instructions and sync README
- `8618dec` docs: restructure README for better flow and clarity
- `3d6bbcf` fix: correct tool_input JSON path in all three hook scripts
- `f594b83` security: add permissions.deny for credential reads and settings protection
- `5f5d067` feat: add notify hook, explain-code skill, and code-reviewer agent
- `36cd265` feat: add global /push skill and branch safety check to /commit
- `7e66cc3` feat: add secret scan hooks, fix python tooling, add global /commit skill
```

---

## Quality Checklist

Before releasing, verify:
- [ ] On `main` branch
- [ ] Working tree is clean (no uncommitted changes)
- [ ] Remote tags fetched and no version collision
- [ ] All commits are meaningful and well-formatted
- [ ] Version number follows SemVer
- [ ] Release notes are categorized and specific
- [ ] Tag annotation has context sentence
- [ ] CHANGELOG.md updated and committed
- [ ] User confirmed the release plan before execution

## Important Notes

- NEVER release with uncommitted changes
- NEVER release without meaningful release notes
- NEVER release without user confirmation of the release plan
- Always fetch remote tags before creating a new tag
- Always use annotated tags (`git tag -a`)
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- First release defaults to `v1.0.0` (this is a stable, intentional config — not a pre-release `v0.x`)
- Release notes should explain "what's in this release" not just list commits
- NO AI attribution in release notes or tag annotations
- Title format: always `v<VERSION> - <Short Title>` with a regular hyphen, never an em dash
