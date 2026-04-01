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

   Run in parallel:
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

   If the tag already exists, **ABORT** and suggest the next available version.

3. **Determine Version and Title**

   Title format: `v<VERSION> - <Short Title>` (regular hyphen, NOT em dash).

   **If version provided**: use it. Auto-generate title if not provided.
   **If no version provided**: auto-bump from commits since last tag:
   - `BREAKING CHANGE` in body or `!:` → **major**
   - `feat:` → **minor**
   - `fix:`, `docs:`, `chore:`, `refactor:`, `infra:` → **patch**
   - No previous tags → default to `v1.0.0`

4. **Check CHANGELOG.md**

   ```bash
   grep -q "## \[v<VERSION>\]" CHANGELOG.md 2>/dev/null
   ```

   If entry already exists, skip CHANGELOG update entirely.

5. **Analyze Changes for Release Notes**

   Get commits since last tag and group by category:
   - Features (`feat:`)
   - Bug Fixes (`fix:`)
   - Infrastructure (`infra:`)
   - Documentation (`docs:`)
   - Chores (`chore:`, `refactor:`)

   Omit empty categories. Descriptions should be human-readable, not raw commits.

6. **Show Release Plan and Confirm**

   ```
   Release Plan:
     Version:    v<VERSION>
     Title:      v<VERSION> - <Short Title>
     Commits:    <N> since <last-tag>
     CHANGELOG:  Will update / Already up to date / Will create
     Remote:     origin

   Pre-release checks:
     ✓ Clean working tree
     ✓ On main
     ✓ No tag collision

   Release notes preview:
     <categorised list>
   ```

   **Do NOT proceed until user confirms.**

7. **Update CHANGELOG.md** (if needed)

   If no entry exists for this version, prepend after the header:

   ```markdown
   ## [v<VERSION>](https://github.com/<owner>/<repo>/releases/tag/v<VERSION>) - <YYYY-MM-DD>

   <One sentence summary>

   ### Added
   - ...

   ### Fixed
   - ...

   ### Changed
   - ...
   ```

   Only include sections that have items. Derive `<owner>/<repo>` from `git remote get-url origin`.

   Commit the changelog:
   ```bash
   git add CHANGELOG.md
   git commit -m "docs: update CHANGELOG for v<VERSION>"
   ```

8. **Execute Release**

   ```bash
   # Create annotated tag
   git tag -a v<VERSION> -m "<tag annotation with summary>"

   # Push commits + tag
   git push origin main
   git push origin v<VERSION>
   ```

   **Verify push succeeded** before creating the release:
   ```bash
   git ls-remote origin refs/tags/v<VERSION>
   ```

   If tag is not on remote, **ABORT** and report the error.

   ```bash
   # Create GitHub release (derive repo from remote)
   REPO=$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')
   gh release create v<VERSION> \
     --repo "$REPO" \
     --title "v<VERSION> - <Short Title>" \
     --notes "<release notes markdown>"
   ```

9. **Report Results**

   ```
   Release complete:
     Tag:       v<VERSION>
     Title:     v<VERSION> - <Short Title>
     Pushed:    origin
     Release:   <URL>
     CHANGELOG: Updated / Skipped
   ```

## Hard Stops

- **Dirty working tree** — never release with uncommitted changes
- **Tag collision** — never overwrite an existing tag
- **No user confirmation** — always wait for explicit approval
- **Force push** — never use `--force`
- **Push failed** — abort before creating GitHub release
- **NO AI attribution** in release notes, tags, or commits
