# Chezmoi Edits

Show local file changes that should be captured into chezmoi.

---

## Key Question

> "What local changes haven't been captured in chezmoi yet?"

**Direction:** Local → Chezmoi source (what you've changed that chezmoi doesn't know about)

---

## Gather

```bash
CHEZMOI_DIR="$HOME/.local/share/chezmoi"

echo "=== Local Edits to Capture ==="

# Files managed by chezmoi that differ locally
echo -e "\n--- Modified (tracked, changed locally) ---"
chezmoi diff 2>&1 | grep "^diff --git" | while read line; do
  # Extract the file path
  file=$(echo "$line" | sed 's/.*b\///' | sed 's/dot_/./g')
  # Count changes
  changes=$(chezmoi diff "$HOME/$file" 2>/dev/null | grep -c "^[-+]" | tr -d ' ')
  echo "  M ~/$file ($changes lines)"
done

# Files in common chezmoi-tracked directories that aren't managed
echo -e "\n--- New (not tracked by chezmoi) ---"
for dir in ~/.cursor/rules ~/.cursor/commands ~/.cursor/agents; do
  [ -d "$dir" ] || continue
  find "$dir" -type f -name "*.md" -o -name "*.mdc" 2>/dev/null | while read f; do
    chezmoi managed | grep -q "$(echo "$f" | sed "s|$HOME/||")" || echo "  ? $f"
  done
done | head -20

# Chezmoi git status (already staged/modified in source)
echo -e "\n--- Chezmoi Git Status ---"
cd "$CHEZMOI_DIR"
git status --short 2>/dev/null

# Remote sync status
echo -e "\n--- Remote Status ---"
git fetch origin --quiet 2>/dev/null
AHEAD=$(git rev-list --count HEAD...origin/main --left-only 2>/dev/null || echo "?")
BEHIND=$(git rev-list --count HEAD...origin/main --right-only 2>/dev/null || echo "?")
echo "Commits: $AHEAD ahead, $BEHIND behind"
```

---

## Output Format

```markdown
## Local Edits to Capture

### Modified (tracked by chezmoi, changed locally)
| Local File | Lines Changed | Action |
|------------|---------------|--------|
| ~/.cursor/rules/dialogue/catch-up.md | 45 | `chezmoi re-add` |
| ~/.cursor/commands/update.md | 12 | `chezmoi re-add` |
| ~/.zshrc | 3 | `chezmoi re-add` |

### New (not tracked by chezmoi)
| Local File | Action |
|------------|--------|
| ~/.cursor/rules/dialogue/sweep-status.md | `chezmoi add` |
| ~/.cursor/commands/chezmoi/diff.md | `chezmoi add` |

### Deleted Locally (still in chezmoi)
| Chezmoi Path | Action |
|--------------|--------|
| dot_cursor/old-rule.md | `chezmoi forget` or `chezmoi apply` to restore |

### Already in Chezmoi Git (uncommitted)
- M dot_cursor/rules/etiquette.md
- A dot_cursor/commands/new-cmd.md

### Quick Capture Commands
```bash
# Re-add all modified tracked files
chezmoi re-add ~/.cursor/rules ~/.cursor/commands ~/.cursor/agents

# Add specific new file
chezmoi add ~/.cursor/commands/chezmoi/diff.md

# Add and commit
chezmoi re-add ~/.cursor && cd ~/.local/share/chezmoi && git add -A && git commit -m "[cfg] sync"
```
```

---

## File Categories

| Category | Meaning | Action |
|----------|---------|--------|
| **Modified** | Chezmoi tracks it, you changed it locally | `chezmoi re-add <file>` |
| **New** | Exists locally, not in chezmoi | `chezmoi add <file>` |
| **Deleted** | In chezmoi, deleted locally | `chezmoi forget` or restore |
| **Staged** | Already in chezmoi git, uncommitted | `git commit` |

---

## Common Capture Patterns

```bash
# Cursor config (most common)
chezmoi re-add ~/.cursor/rules ~/.cursor/commands ~/.cursor/agents

# Shell config
chezmoi re-add ~/.zshrc ~/.bashrc ~/.zprofile

# Git config
chezmoi re-add ~/.gitconfig ~/.gitignore_global

# Specific file
chezmoi re-add ~/.cursor/rules/etiquette.md

# Add new file to tracking
chezmoi add ~/.cursor/commands/chezmoi/edits.md
```

---

## Verify Capture

After re-adding:

```bash
# Check chezmoi git status
cd ~/.local/share/chezmoi && git status

# Verify diff is now empty
chezmoi diff  # Should show nothing if fully captured
```

---

## Follow-Up

| Situation | Question |
|-----------|----------|
| Has modified files | "Capture these with `chezmoi re-add`?" |
| Has new files | "Add these to chezmoi tracking?" |
| Has deleted files | "Forget from chezmoi or restore locally?" |
| Nothing to capture | "All synced. Run `/chezmoi/commit` to commit?" |

---

## Related Commands

| Need | Command |
|------|---------|
| See what apply would do | → `/chezmoi/diff` |
| Capture and commit | → `/chezmoi/commit` |
| Full sync diagnostics | → `/sync/chezmoi` |

