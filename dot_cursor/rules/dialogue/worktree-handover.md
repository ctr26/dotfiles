# Worktree Handover Dialogue Template

Transfer context when switching between git worktrees.

---

## When to Use

- Switching from one worktree to another
- Starting work in a different feature branch
- Coordinating work across multiple features
- Handing off between agents in different worktrees

---

## Gather

```bash
echo "=== Worktree Handover ==="

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)

# Detect if in worktree
GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "$GIT_COMMON_DIR" ] && [ -n "$GIT_COMMON_DIR" ]; then
  MAIN_REPO=$(dirname "$GIT_COMMON_DIR")
  echo "Current: WORKTREE at $REPO_ROOT"
  echo "Main repo: $MAIN_REPO"
else
  MAIN_REPO="$REPO_ROOT"
  echo "Current: MAIN REPO at $REPO_ROOT"
fi

# List all worktrees with status
echo -e "\n--- All Worktrees ---"
git worktree list --porcelain | grep "^worktree " | cut -d' ' -f2 | while read wt; do
  branch=$(git -C "$wt" branch --show-current 2>/dev/null || echo "detached")
  status=$(git -C "$wt" status --short 2>/dev/null | wc -l | tr -d ' ')
  has_claude=$([ -f "$wt/CLAUDE.md" ] && echo "✓" || echo "-")
  
  # Mark current
  marker=""
  [ "$wt" = "$REPO_ROOT" ] && marker=" ← current"
  
  echo "$wt | $branch | ${status} changes | claude:$has_claude$marker"
done

# CLAUDE.md summaries (if accessible)
echo -e "\n--- Context per Worktree ---"
git worktree list --porcelain | grep "^worktree " | cut -d' ' -f2 | while read wt; do
  if [ -f "$wt/CLAUDE.md" ]; then
    focus=$(grep -m1 "^\*\*Focus:\*\*" "$wt/CLAUDE.md" 2>/dev/null | sed 's/\*\*Focus:\*\* //')
    [ -n "$focus" ] && echo "$(basename "$wt"): $focus"
  fi
done

# Current worktree uncommitted work
echo -e "\n--- Current Worktree Status ---"
git status --short
git stash list | head -3
```

---

## Output Format

```markdown
## Worktree Handover

**From:** `/path/to/feat-a` (`feat/a`) → **To:** `/path/to/feat-b` (`feat/b`)

### All Worktrees
| Path | Branch | Changes | Context |
|------|--------|---------|---------|
| /repo | main | 0 | "Main development" |
| /repo-prs/feat-a | feat/a | 2 | "Adding auth flow" ← current |
| /repo-prs/feat-b | feat/b | 0 | "No CLAUDE.md" |

### Current Worktree (`feat/a`)
**Uncommitted:**
- M src/auth.py
- M tests/test_auth.py

**Stashes:** 1 (WIP on feat/a: abc123)

### Carry Forward
- [Knowledge/context that applies to target worktree]
- [Shared dependencies or patterns]

### Leave Behind
- [Work specific to current worktree]
- [Uncommitted changes to handle]
```

---

## Handover Checklist

Before switching worktrees:

- [ ] Commit or stash uncommitted changes
- [ ] Update CLAUDE.md with current state
- [ ] Note any cross-worktree dependencies
- [ ] Record what to pick up in target worktree

---

## Cross-Worktree Dependencies

When features depend on each other:

```markdown
### Dependencies
| Feature A | Depends On | Feature B |
|-----------|------------|-----------|
| feat/api | needs | feat/auth (in progress) |
| feat/ui | needs | feat/api (merged) |
```

---

## Fallbacks

| Missing | Show Instead |
|---------|--------------|
| Single worktree | "Only main repo - no worktrees" |
| No CLAUDE.md in target | "No context in target - create one?" |
| Uncommitted in current | "Handle uncommitted changes first?" |
| Can't read other worktree | "Cannot access [path] - open in Cursor or symlink" |

---

## Follow-Up

| Situation | Question |
|-----------|----------|
| Has uncommitted changes | "Commit, stash, or carry these to the new worktree?" |
| Target has no CLAUDE.md | "Create CLAUDE.md in target worktree?" |
| Multiple worktrees available | "Which worktree do you want to switch to?" |
| Dependencies detected | "Should I note the dependency in both CLAUDE.md files?" |

---

## Related

| Need | Use Instead |
|------|-------------|
| Discover worktree visibility | → `/git/worktrees` |
| Create new worktree | → `/git/worktree` |
| Full session handover | → `/session/handover` |
| PR management | → `/git/pr` |

