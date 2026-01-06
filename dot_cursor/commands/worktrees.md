# Worktrees

You help agents understand worktree context. Files may exist in other worktrees that the agent cannot see directly.

## Why This Matters

When a repo uses git worktrees:
- Each worktree has its own working directory
- An agent opened in one worktree cannot see files in another
- Users may reference files that exist in a different worktree
- CLAUDE.md and notes are per-worktree (isolated context)

---

## First: Discover Worktrees

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Detect if we're in a worktree
GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)

echo "=== Worktree Context ==="
if [ "$GIT_DIR" != "$GIT_COMMON_DIR" ] && [ -n "$GIT_COMMON_DIR" ]; then
  MAIN_REPO=$(dirname "$GIT_COMMON_DIR")
  echo "You are in a WORKTREE"
  echo "  Current worktree: $REPO_ROOT"
  echo "  Main repo: $MAIN_REPO"
  echo "  Branch: $(git branch --show-current)"
else
  echo "You are in the MAIN REPO"
  echo "  Path: $REPO_ROOT"
  echo "  Branch: $(git branch --show-current)"
fi

echo ""
echo "=== All Worktrees ==="
git worktree list
```

---

## Worktree Visibility Report

After discovering worktrees, explain what the agent can and cannot see:

```
## Worktree Visibility

**Current workspace:** /path/to/repo-prs/feat-xyz
**Branch:** feat/xyz

### Accessible (this workspace)
- All files in /path/to/repo-prs/feat-xyz/

### Not Accessible (other worktrees)
| Path | Branch | Notes |
|------|--------|-------|
| /path/to/repo | main | Main repo |
| /path/to/repo-prs/feat-abc | feat/abc | Another feature |

Files in other worktrees exist but I cannot read them directly.
To access them:
1. Open that worktree in Cursor, or
2. Create a symlink (see below)
```

---

## Symlink Commands

If the user needs to access files from another worktree:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
OTHER_WORKTREE="/path/to/other/worktree"

# Create external directory for cross-worktree access
mkdir -p "$REPO_ROOT/external"

# Symlink a specific file
ln -sfn "$OTHER_WORKTREE/path/to/file" "$REPO_ROOT/external/filename"

# Symlink the entire worktree
ln -sfn "$OTHER_WORKTREE" "$REPO_ROOT/external/other-worktree"
```

---

## Per-Worktree Context

Each worktree maintains its own agent context:

| File | Location | Purpose |
|------|----------|---------|
| `CLAUDE.md` | `$WORKTREE/CLAUDE.md` | Session index for this feature |
| `CLAUDE/` | `$WORKTREE/CLAUDE/` | Notes, sessions, decisions for this feature |
| `.specstory/` | `$WORKTREE/.specstory/` | Chat history for this worktree |

**Main repo CLAUDE.md is separate from worktree CLAUDE.md** - they track different features.

---

## Check All Worktree Contexts

```bash
# List CLAUDE.md files across all worktrees
git worktree list --porcelain | grep "^worktree " | cut -d' ' -f2 | while read wt; do
  echo "=== $wt ==="
  if [ -f "$wt/CLAUDE.md" ]; then
    echo "Has CLAUDE.md:"
    head -10 "$wt/CLAUDE.md" | grep -v "AGENT-GENERATED"
  else
    echo "No CLAUDE.md"
  fi
  echo ""
done
```

---

## Common Scenarios

### User References a File You Can't See

> "Look at the changes in feat/abc branch"

**Response:**
> "I'm in the `feat/xyz` worktree and can't see `feat/abc` directly. Options:
> 1. Open the feat/abc worktree in Cursor
> 2. Create a symlink: `ln -sfn /path/to/feat-abc /path/to/feat-xyz/external/feat-abc`
> 3. Tell me the specific file path and I'll check if it exists in git history"

### User Asks About Main Repo

> "What's in the main repo?"

```bash
# Get main repo path
GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
MAIN_REPO=$(dirname "$GIT_COMMON_DIR")
echo "Main repo is at: $MAIN_REPO"
echo "I cannot read files there directly. Open it in Cursor or create symlinks."
```

### Comparing Worktrees

```bash
# Compare file between worktrees (if user runs this)
diff "$WORKTREE_A/path/to/file" "$WORKTREE_B/path/to/file"

# Or use git to compare branches
git diff feat/abc..feat/xyz -- path/to/file
```

---

## Output Format

When activated, provide a clear summary:

```
## Worktrees for this repo

**Current:** /home/user/repo-prs/feat-xyz (branch: feat/xyz)

**Other worktrees I cannot see:**
| Path | Branch |
|------|--------|
| /home/user/repo | main |
| /home/user/repo-prs/feat-abc | feat/abc |

If you reference files in another worktree, I'll need you to:
- Open that worktree in Cursor, or
- Create a symlink, or  
- Paste the file contents
```

---

## Always End With a Question

| Situation | Question |
|-----------|----------|
| Multiple worktrees found | "Which worktree are you asking about?" |
| User references inaccessible file | "Want me to generate symlink commands, or should you open that worktree?" |
| Single worktree (main repo) | "No other worktrees found. Need to create one for a feature branch?" |

---

## Related Commands

| Need | Command |
|------|---------|
| Create a note for this worktree | → **note** |
| Session handover | → **handover** |
| PR management with worktrees | → **pr-manager** |
| Check overall status | → **update** |




