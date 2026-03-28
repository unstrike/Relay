---
name: changelog
description: "Generate formatted release notes from git commits since the last tag. Use whenever the user wants to generate a changelog, prepare release notes, or preview what changed since the last version."
---

# Changelog Skill

Generate formatted release notes from git commits since the last version tag.

## Steps

1. Run `bin/changelog` to preview the output:
   ```bash
   bin/changelog
   ```

2. Show the output to the user so they can review and edit commit lines.

3. Ask the user if they want to copy it to clipboard:
   ```bash
   bin/changelog --copy
   ```

4. If the user wants to edit the output, capture `bin/changelog`, apply their edits, then display the final result.

## Commit Categorisation

The script auto-categorises by commit message prefix:
- `Add*` / `add*` → **Added**
- `Fix*` / `fix*` → **Fixed**
- `Update*` / `Improve*` / `Change*` / `Revise*` → **Changed**
- Everything else → uncategorised `<li>`

PR numbers are stripped automatically: `Fix thing (#123)` → `Fix thing`.

## Notes

- Requires at least one git tag to determine range; warns if none found
- Merge commits are excluded (`--no-merges`)
