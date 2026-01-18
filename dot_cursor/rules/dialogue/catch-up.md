# Catch-Up Dialogue Template

Quick context recovery when returning to work. Lighter than `/session/continue`.

---

## When to Use

- Returning after a break (hours, not days)
- Quick orientation before diving in
- Context refresh mid-session

---

## Gather

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

echo "=== Quick Catch-Up ==="

# Branch and worktree
BRANCH=$(git branch --show-current 2>/dev/null || echo "none")
GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "$GIT_COMMON_DIR" ] && [ -n "$GIT_COMMON_DIR" ]; then
  echo "Worktree: $REPO_ROOT"
  echo "Main repo: $(dirname "$GIT_COMMON_DIR")"
else
  echo "Repo: $REPO_ROOT"
fi
echo "Branch: $BRANCH"

# Last activity (most recent commit time)
LAST_COMMIT=$(git log -1 --format="%cr" 2>/dev/null || echo "unknown")
echo "Last commit: $LAST_COMMIT"

# Last 3 commits
echo -e "\n--- Recent Commits ---"
git log --oneline -3 2>/dev/null || echo "(no commits)"

# Uncommitted changes
echo -e "\n--- Pending Changes ---"
git status --short 2>/dev/null || echo "(not a git repo)"
git stash list 2>/dev/null | head -3

# CLAUDE.md summary
echo -e "\n--- Context ---"
if [ -f "$REPO_ROOT/CLAUDE.md" ]; then
  grep -E "^\*\*Focus:\*\*|^\*\*Branch:\*\*|^## Current|^- \[ \]" "$REPO_ROOT/CLAUDE.md" 2>/dev/null | head -5
else
  echo "No CLAUDE.md"
fi
```

---

## Output Format

```markdown
## Quick Catch-Up

**Branch:** `feat/x` | **Worktree:** /path/to/worktree
**Last active:** 2 hours ago

### Recent Commits
- abc123 [feat] add auth flow
- def456 [fix] token refresh
- ghi789 [ref] extract helper

### Pending
- 2 files modified
- 1 stash

### Context
[One-liner from CLAUDE.md Focus, or "No CLAUDE.md"]

### In Progress
[From CLAUDE.md pending items or recent changes]
```

---

## Fallbacks

| Missing | Show Instead |
|---------|--------------|
| No CLAUDE.md | "No context file - create one?" |
| No commits | "Fresh repo or new branch" |
| No changes | "Clean working tree" |
| Not a git repo | "Not a git repository" |

---

## Follow-Up

After presenting catch-up, ask:

| Situation | Question |
|-----------|----------|
| Has pending changes | "Continue with these changes, or review first?" |
| Has CLAUDE.md with pending items | "Pick up where you left off with [first pending]?" |
| Clean state | "What would you like to work on?" |

---

## Related

| Need | Use Instead |
|------|-------------|
| Full context recovery with plan | → `/session/continue` |
| End of day wrap-up | → `/session/eod` |
| Session handover | → `/session/handover` |

