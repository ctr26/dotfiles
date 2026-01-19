# Catch-Up Session

Read-only context ingestion. No edits until user confirms focus.

See #CONTEXT for environment setup.

---

## When to Use

- Returning after a break (hours or days)
- Orientation before diving into unfamiliar code
- Context refresh mid-session
- New agent picking up existing work

---

## What It Reads

| Source | Purpose |
|--------|---------|
| `CLAUDE.md` | Current handover pointer |
| `CLAUDE/` folder | Recent handover files |
| `.specstory/history/*.md` | Last 5 session histories |
| `git log --oneline -10` | Recent commits |
| `git status` | Uncommitted changes |
| `git diff --stat` | Change summary |

---

## Gather Context

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

echo "=== Catch-Up Context ==="

# Branch and worktree detection
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

# Last activity
LAST_COMMIT=$(git log -1 --format="%cr" 2>/dev/null || echo "unknown")
echo "Last commit: $LAST_COMMIT"

# Recent commits
echo -e "\n--- Recent Commits (10) ---"
git log --oneline -10 2>/dev/null || echo "(no commits)"

# Uncommitted changes
echo -e "\n--- Pending Changes ---"
git status --short 2>/dev/null || echo "(not a git repo)"

# Diff summary
echo -e "\n--- Diff Summary ---"
git diff --stat 2>/dev/null | tail -5 || echo "(no changes)"

# Stashes
echo -e "\n--- Stashes ---"
git stash list 2>/dev/null | head -3 || echo "(none)"

# CLAUDE.md
echo -e "\n--- CLAUDE.md ---"
if [ -f "$REPO_ROOT/CLAUDE.md" ]; then
  cat "$REPO_ROOT/CLAUDE.md"
else
  echo "No CLAUDE.md"
fi

# CLAUDE/ folder
echo -e "\n--- Handover Files ---"
ls -lt "$REPO_ROOT/CLAUDE/"*.md 2>/dev/null | head -3 || echo "(none)"

# .specstory history
echo -e "\n--- Recent Session History ---"
ls -lt "$REPO_ROOT/.specstory/history/"*.md 2>/dev/null | head -5 || echo "(none)"
```

---

## Read Recent Sessions

After gathering, read the most recent `.specstory/history/*.md` file to understand what happened last session:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
LATEST=$(ls -t "$REPO_ROOT/.specstory/history/"*.md 2>/dev/null | head -1)
if [ -n "$LATEST" ]; then
  echo "=== Latest Session: $LATEST ==="
  head -100 "$LATEST"
fi
```

---

## Output Format

Present a digestible summary:

```markdown
## Catch-Up Summary

**Branch:** `feat/x` | **Last active:** 2 hours ago
**Worktree:** /path/to/worktree (if applicable)

### Recent Commits
- abc123 [feat] add auth flow
- def456 [fix] token refresh
- ghi789 [ref] extract helper

### Pending Changes
- 2 files modified (`src/auth.py`, `tests/test_auth.py`)
- 1 stash: "WIP: token refresh"

### From CLAUDE.md
**Focus:** [from handover]
**Pending:** 
- [ ] First pending item
- [ ] Second pending item

### From Last Session
[Brief summary of .specstory history if available]
```

---

## Follow-Up: Focus Selection

After presenting context, use `ask_question` to determine focus:

```
ask_question(
  title="What should we focus on?",
  options=[
    {"id": "pending", "label": "Continue pending items from CLAUDE.md"},
    {"id": "uncommitted", "label": "Review uncommitted changes"},
    {"id": "fresh", "label": "Start a fresh task"},
    {"id": "browse", "label": "Just browsing (stay read-only)"}
  ]
)
```

---

## Constraints

| Do | Don't |
|----|-------|
| Read all context sources | Make any edits |
| Summarize findings | Run terminal commands (except gather) |
| Use ask_question for focus | Assume what user wants |
| Present options | Start working without confirmation |

---

## Fallbacks

| Missing | Show Instead |
|---------|--------------|
| No CLAUDE.md | "No context file - create one after confirming focus?" |
| No commits | "Fresh repo or new branch" |
| No changes | "Clean working tree - ready for new work" |
| No .specstory | "No session history available" |
| Not a git repo | "Not a git repository - limited context" |

---

## After Focus Selection

| User Choice | Next Action |
|-------------|-------------|
| Continue pending | Start with first pending item from CLAUDE.md |
| Review uncommitted | Show `git diff` and discuss changes |
| Fresh task | Ask what they want to work on |
| Just browsing | Stay in read-only mode, answer questions |

---

## Related Commands

| Need | Use Instead |
|------|-------------|
| Full planning mode | → `/session/continue` |
| End of day wrap-up | → `/session/eod` |
| Session handover | → `/session/handover` |
| Observer mode only | → `/session/read-only` |

