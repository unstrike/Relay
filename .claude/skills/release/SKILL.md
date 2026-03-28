---
name: release
description: "Tag and push a new Relay release. Use whenever the user says 'release', 'ship', 'publish a new version', or wants to tag the current state."
---

# Release Skill

Relay is source-only — a release is a git tag pushed to GitHub.

## Steps

### 1. Preflight

```bash
git status
agvtool what-marketing-version
agvtool what-version
```

### 2. Bump version

```bash
bin/bump X.Y.Z
```

Pass the new marketing version (e.g. `2.1.0`). Sets both the marketing version and build number (from git commit count) across all targets. Commit all work before bumping.

To bump build number only (no version change): `bin/bump`

### 3. Generate changelog

```bash
bin/changelog
```

Show output to user, allow edits.

### 4. Commit and tag

```bash
git add -A
git commit -m "Release vX.Y.Z"
git tag vX.Y.Z
git push origin main --tags
```

### 5. Confirm

```bash
git log --oneline -3
```

## Notes

- `bin/bump X.Y.Z` sets both marketing version and build number — commit all work first
- Marketing version maps to "About" panel display; build number is git commit count
- Tags trigger CI; ensure tests pass before tagging
