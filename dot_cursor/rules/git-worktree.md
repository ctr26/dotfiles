# Git Worktree Patterns

Common patterns for working with git worktrees.

---

## Core Commands

```bash
# List all worktrees
git worktree list

# Create worktree with new branch
git worktree add worktrees/<name> -b feat/<name> origin/dev

# Create worktree from existing branch
git worktree add worktrees/<name> feat/<name>

# Remove worktree
git worktree remove worktrees/<name>

# Prune stale worktree references
git worktree prune
```

---

## Creation Script

Use the setup script for consistent worktree creation:

```bash
~/.cursor/scripts/new-worktree.sh <branch-name> [path]
```

This script:
- Creates worktree with new branch
- Symlinks common resources (.env, .venv, node_modules, etc.)
- Creates fresh CLAUDE.md for the feature

---

## What to Symlink vs Keep Local

| Resource | Symlink? | Reason |
|----------|----------|--------|
| `.env`, `.envrc` | Yes | Secrets should be shared |
| `.venv`, `venv` | Yes | Avoid reinstalling packages |
| `node_modules` | Yes | Avoid reinstalling packages |
| `.python-version` | Yes | Consistent Python version |
| `.cache`, `*_cache` | Yes | Avoid re-downloading |
| `outputs/`, `wandb/` | No | Keep separate per feature |
| `logs/` | No | Keep separate per feature |
| `CLAUDE.md` | No | Per-feature context (isolated) |
| `CLAUDE/` | No | Session history is per-feature |

---

## Per-Worktree Context

**Each worktree gets its own CLAUDE.md** - do NOT symlink from main repo.

This keeps session context isolated per feature:
- Different features have different plans
- Handovers are feature-specific
- No cross-contamination of notes

```bash
# Detect if in worktree
GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "$GIT_COMMON_DIR" ] && [ -n "$GIT_COMMON_DIR" ]; then
    echo "In worktree: $(git rev-parse --show-toplevel)"
    echo "Main repo: $(dirname "$GIT_COMMON_DIR")"
fi
```

---

## Worktree Tracking

Track active worktrees in `~/.cursor/CLAUDE/worktrees/README.md`:

| Worktree | Branch | Purpose | Status |
|----------|--------|---------|--------|
| worktrees/feat-auth | feat/auth | Authentication refactor | active |

Update when creating/removing worktrees.

---

## Cleanup

When a feature is merged:

```bash
# Remove the worktree
git worktree remove worktrees/<name>

# Delete the branch if merged
git branch -d feat/<name>

# Prune any stale references
git worktree prune
```

---

## Related Commands

| Need | Command |
|------|---------|
| Create new worktree | `@new-worktree` |
| Worktree context/visibility | `@worktrees` |
| PR management with worktrees | `@pr-manager` |


