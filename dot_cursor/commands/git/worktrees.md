# Worktrees

Help agents understand worktree context. Files may exist in other worktrees that the agent cannot see directly.

---

## Discover Worktrees

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)

echo "=== Worktree Context ==="
if [ "$GIT_DIR" != "$GIT_COMMON_DIR" ] && [ -n "$GIT_COMMON_DIR" ]; then
  MAIN_REPO=$(dirname "$GIT_COMMON_DIR")
  echo "WORKTREE: $REPO_ROOT | Main: $MAIN_REPO | Branch: $(git branch --show-current)"
else
  echo "MAIN REPO: $REPO_ROOT | Branch: $(git branch --show-current)"
fi
echo ""
git worktree list
```

---

## Visibility Summary

After discovering, report what the agent can/cannot see:

```
**Current:** /path/to/repo-prs/feat-xyz (branch: feat/xyz)

**Other worktrees (not accessible):**
| Path | Branch |
|------|--------|
| /path/to/repo | main |
```

---

## Per-Worktree Context

| File | Location | Purpose |
|------|----------|---------|
| `CLAUDE.md` | `$WORKTREE/CLAUDE.md` | Session index for this feature |
| `CLAUDE/` | `$WORKTREE/CLAUDE/` | Notes, sessions, decisions |
| `.specstory/` | `$WORKTREE/.specstory/` | Chat history |

**Main repo CLAUDE.md is separate from worktree CLAUDE.md** - they track different features.

---

## Symlink Commands

For cross-worktree file access:

```bash
mkdir -p "$REPO_ROOT/external"
ln -sfn "/path/to/other/worktree" "$REPO_ROOT/external/other-wt"
```

---

## Common Scenarios

| Situation | Response |
|-----------|----------|
| User references file in other worktree | Offer: open that worktree, create symlink, or use `git show branch:path` |
| User asks about main repo | Report main repo path, explain visibility limits |
| Comparing worktrees | Use `git diff branch1..branch2 -- path` |

---

## Follow-Up Questions

| Situation | Question |
|-----------|----------|
| Multiple worktrees found | "Which worktree are you asking about?" |
| User references inaccessible file | "Want symlink commands, or open that worktree?" |
| Single worktree (main repo) | "Need to create a worktree for a feature branch?" |

---

## Related Commands

| Need | Command |
|------|---------|
| Create worktree | → **git/worktree** |
| Session handover | → **session/handover** |
| PR management | → **git/pr** |
