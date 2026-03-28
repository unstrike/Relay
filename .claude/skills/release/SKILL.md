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
bin/bump
```

Sets the build number (based on git commit count) across all `Info.plist` files. Commit all work before bumping.

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

- `bin/bump` uses git commit count as build number — commit all work before bumping
- Tags trigger CI; ensure tests pass before tagging
