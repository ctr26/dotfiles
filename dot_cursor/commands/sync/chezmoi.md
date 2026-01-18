# Chezmoi Sync Manager

You manage dotfile synchronization between local, chezmoi source, and GitHub.

---

## First: Check Sync Status

Run this diagnostic to identify desync issues:

```bash
CHEZMOI_DIR="$HOME/.local/share/chezmoi"
cd "$CHEZMOI_DIR"

echo "=== 1. Local → Chezmoi (would chezmoi overwrite local?) ==="
chezmoi diff 2>&1 | grep "^diff --git" || echo "✓ No diff"

echo ""
echo "=== 2. Chezmoi git status (uncommitted changes) ==="
git status --short

echo ""
echo "=== 3. Local ↔ Remote (commits ahead/behind) ==="
git fetch origin --quiet
git rev-list --left-right --count HEAD...origin/main | awk '{print "Ahead: "$1", Behind: "$2}'

echo ""
echo "=== 4. Managed files summary ==="
chezmoi managed | wc -l | xargs echo "Files managed:"
```

---

## Interpreting Results

| Section | Issue | Fix |
|---------|-------|-----|
| Local → Chezmoi diff | Files would change on apply | `chezmoi re-add <file>` to capture local changes |
| Git status (modified) | Local edits not committed | `git add && git commit` |
| Git status (untracked) | New files not tracked | `chezmoi add <file>` |
| Ahead of remote | Commits not pushed | `git push origin main` |
| Behind remote | Remote has new commits | `chezmoi update` (pulls and applies) |

---

## Quick Actions

**Capture local changes into chezmoi:**
```bash
chezmoi re-add ~/.cursor/commands ~/.cursor/rules ~/.cursorignore
```

**See what chezmoi would change locally:**
```bash
chezmoi diff
```

**Apply chezmoi to local (dry run first):**
```bash
chezmoi apply --dry-run --verbose
chezmoi apply --force
```

**Pull remote and apply:**
```bash
chezmoi update
```

**Commit and push chezmoi changes:**
```bash
cd ~/.local/share/chezmoi
git add -A && git commit -m "[cfg] sync dotfiles"
git push origin main
```

---

## Workflow

1. Run diagnostic (above)
2. Report sync status in table form
3. Ask: "What should I fix first?"
4. Execute fix with confirmation
5. Re-run diagnostic to verify

---

## Never Do

- `chezmoi apply` without showing diff first
- `git push` without explicit approval
- Overwrite local changes without asking

---

## Example Output

After running diagnostic:

> **Sync Status:**
> | Direction | Status |
> |-----------|--------|
> | Local → Chezmoi | 2 files differ |
> | Chezmoi → Git | 3 uncommitted |
> | Local → Remote | 5 ahead, 0 behind |
>
> "Your local cursor commands have changed. Want me to re-add them to chezmoi?"

---

## Related Commands

| Need | Command |
|------|---------|
| See local edits to capture | → **sync/chezmoi/edits** |
| See what apply would do | → **sync/chezmoi/diff** |
| Capture and commit changes | → **sync/chezmoi/commit** |
| Sync cursor config to remote | → **sync/remote** |

