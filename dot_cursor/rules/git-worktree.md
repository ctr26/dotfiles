---
tag: GIT-WORKTREE
scope: global
---
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

Use the worktree setup script for consistent worktree creation. It:

- Creates worktree with new branch
- Symlinks shared resources (.env, .python-version, node_modules)
- Copies .venv (to avoid breaking the original)
- Creates fresh CLAUDE.md for the feature

---

## What to Symlink vs Copy vs Keep Local

| Resource | Action | Reason |
|----------|--------|--------|
| `.env`, `.envrc` | Symlink | Secrets should be shared |
| `.venv`, `venv` | Copy | Symlink can break original venv |
| `node_modules` | Symlink | Avoid reinstalling packages |
| `.python-version` | Symlink | Consistent Python version |
| `.cache`, `*_cache` | Symlink | Avoid re-downloading |
| `outputs/`, `wandb/` | Local | Keep separate per feature |
| `logs/` | Local | Keep separate per feature |
| `CLAUDE.md` | Local | Per-feature context (isolated) |
| `CLAUDE/` | Local | Session history is per-feature |

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

Track active worktrees in `CLAUDE/worktrees/README.md`:

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
| Create new worktree | → **git/worktree** |
| Worktree context/visibility | → **git/worktrees** |
| PR management with worktrees | → **git/pr** |
