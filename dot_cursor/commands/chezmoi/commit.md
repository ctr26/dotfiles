# Chezmoi Commit

Capture local dotfile changes into chezmoi and commit them. Conflicts deferred to later.

---

## Session Scope

- Add/update local files in chezmoi source
- Commit changes to chezmoi git (not push)
- Report conflicts without resolving

For full sync diagnostics, use → `/sync/chezmoi`

---

## Workflow

1. **Detect** - Find local changes not in chezmoi
2. **Show** - Display what would be captured
3. **Confirm** - User approves
4. **Re-add** - Capture local files into chezmoi source
5. **Commit** - Git commit with `[cfg]` tag
6. **Report** - Show result, conflicts, next steps

---

## 1. Detect Changes

```bash
CHEZMOI_DIR="$HOME/.local/share/chezmoi"

echo "=== Local → Chezmoi Diff ==="
# Files that differ between local and chezmoi source
chezmoi diff 2>&1 | grep "^diff --git" | sed 's/.*a\///' | sed 's/ b\/.*//' | sort -u

echo -e "\n=== Chezmoi Git Status ==="
cd "$CHEZMOI_DIR"
git status --short

echo -e "\n=== Remote Status ==="
git fetch origin --quiet 2>/dev/null
git rev-list --left-right --count HEAD...origin/main 2>/dev/null | awk '{print "Ahead: "$1", Behind: "$2}'
```

---

## 2. Show Changes

Present findings in table format:

```markdown
## Changes to Capture

| Local File | Status | Chezmoi Path |
|------------|--------|--------------|
| ~/.cursor/rules/dialogue/catch-up.md | new | dot_cursor/rules/dialogue/catch-up.md |
| ~/.cursor/commands/update.md | modified | dot_cursor/commands/update.md |
| ~/.zshrc | modified | dot_zshrc |

## Already Staged in Chezmoi Git
- M dot_cursor/rules/etiquette.md
- ?? dot_cursor/new-file.md

## Conflicts
- Behind remote by 2 commits (will resolve later)
```

---

## 3. Confirm

Ask before proceeding:

> "Ready to re-add these files and commit. Proceed?"
> - A) Yes, commit all
> - B) Let me select specific files
> - C) Show diff first

---

## 4. Re-add Files

```bash
# Re-add specific paths (safer than blanket add)
chezmoi re-add ~/.cursor/rules ~/.cursor/commands ~/.cursor/agents

# For new files not yet tracked
chezmoi add ~/.cursor/new-file.md
```

### Common Paths to Re-add

```bash
# Cursor config
chezmoi re-add ~/.cursor/rules ~/.cursor/commands ~/.cursor/agents

# Shell config  
chezmoi re-add ~/.zshrc ~/.bashrc ~/.profile

# Git config
chezmoi re-add ~/.gitconfig ~/.gitignore_global

# Specific file
chezmoi re-add <path>
```

---

## 5. Commit

```bash
cd "$HOME/.local/share/chezmoi"
git add -A
git status --short  # Show what will be committed
git commit -m "[cfg] <description>"
```

### Commit Message Patterns

| Change Type | Message |
|-------------|---------|
| Cursor rules | `[cfg] update cursor rules` |
| Cursor commands | `[cfg] add/update cursor commands` |
| Shell config | `[cfg] sync shell config` |
| Mixed | `[cfg] sync dotfiles` |
| Specific file | `[cfg] update <filename>` |

---

## 6. Report

```markdown
## Chezmoi Commit Complete

### Committed
- 5 files changed
- Commit: `abc1234 [cfg] sync cursor rules`

### Not Committed
- None / [list skipped files]

### Conflicts
- None detected / Behind by 2 commits (resolve with `chezmoi update`)

### Next Steps
| Action | Command |
|--------|---------|
| Push to remote | `cd ~/.local/share/chezmoi && git push` |
| Resolve conflicts | `chezmoi update` (pulls and applies) |
| View log | `cd ~/.local/share/chezmoi && git log --oneline -5` |
```

---

## Never Do

- `git push` without explicit request
- `chezmoi apply` (overwrites local)
- Resolve conflicts automatically
- Re-add files user didn't approve

---

## Conflict Handling

When behind remote:

```markdown
**Conflicts Detected**

Behind remote by 2 commits. Options:
1. Commit anyway (merge later with `chezmoi update`)
2. Pull first: `cd ~/.local/share/chezmoi && git pull`
3. View remote changes: `git log HEAD..origin/main --oneline`

Recommended: Commit now, resolve later with `chezmoi update`
```

---

## Quick Mode

For fast commits without prompts:

```bash
# Quick re-add and commit
chezmoi re-add ~/.cursor/rules ~/.cursor/commands
cd ~/.local/share/chezmoi
git add -A && git commit -m "[cfg] sync cursor config"
```

---

## Follow-Up

| Situation | Question |
|-----------|----------|
| Commit successful | "Push to remote now, or commit more first?" |
| Conflicts detected | "Commit anyway and resolve later, or pull first?" |
| New files found | "Add these new files to chezmoi tracking?" |
| Nothing to commit | "No changes detected. Check specific paths?" |

---

## Related Commands

| Need | Command |
|------|---------|
| Full sync diagnostics | → `/sync/chezmoi` |
| Git commit patterns | → `/git/commit` |
| Check sync status | → `/update` |

