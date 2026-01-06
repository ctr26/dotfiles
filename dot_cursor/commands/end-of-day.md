# End of Day Assistant

**First, follow all rules in `etiquette.md`.**

You are an end-of-day wrap-up assistant. Summarize today's work, check for loose ends, prepare a handover for tomorrow, and verify overnight jobs are healthy.

---

## Mission

- **Summarize the day** – what was accomplished, commits made, files changed
- **Surface loose ends** – uncommitted work, stashes, WIP branches
- **Prepare handover** – create/update CLAUDE.md and handover file if significant WIP exists
- **Overnight check** – verify Slurm jobs running overnight look healthy
- **Tomorrow prep** – generate a startup prompt for tomorrow's session

---

## 1. Gather Today's Work

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

# Detect worktree context
GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "$GIT_COMMON_DIR" ] && [ -n "$GIT_COMMON_DIR" ]; then
    MAIN_REPO=$(dirname "$GIT_COMMON_DIR")
    echo "=== WORKTREE DETECTED ==="
    echo "Worktree: $REPO_ROOT"
    echo "Main repo: $MAIN_REPO"
fi

# Today's commits (since 6am local time)
echo "=== TODAY'S COMMITS ==="
git log --oneline --since="6am" --author="$(git config user.email)" 2>/dev/null || \
git log --oneline --since="6am" 2>/dev/null | head -20

# Current branch
echo -e "\n=== CURRENT BRANCH ==="
git branch --show-current

# All branches touched today
echo -e "\n=== BRANCHES WITH RECENT COMMITS ==="
git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:relative)' refs/heads/ | head -10
```

---

## 2. Check Outstanding Work

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

# Uncommitted changes
echo "=== UNCOMMITTED CHANGES ==="
git status --short

# Stashes
echo -e "\n=== STASHES ==="
git stash list

# Untracked files (limited)
echo -e "\n=== UNTRACKED FILES ==="
git ls-files --others --exclude-standard | head -15

# Check for merge conflicts
echo -e "\n=== MERGE STATE ==="
if [ -f ".git/MERGE_HEAD" ] || [ -d ".git/worktrees" ] && find .git/worktrees -name "MERGE_HEAD" 2>/dev/null | grep -q .; then
    echo "MERGE IN PROGRESS - resolve before leaving"
else
    echo "No merge in progress"
fi
```

---

## 3. Check Overnight Jobs (Slurm)

```bash
# Current jobs with time estimates
echo "=== RUNNING JOBS ==="
squeue -u $USER --format="%.10i %.30j %.8T %.10M %.12l %.6D %R" 2>/dev/null | head -20

# Jobs that might finish overnight (check time limit vs elapsed)
echo -e "\n=== JOB TIME ANALYSIS ==="
squeue -u $USER --format="%i %j %M %l" --noheader 2>/dev/null | while read jobid name elapsed limit; do
    echo "Job $jobid ($name): $elapsed elapsed of $limit limit"
done | head -10

# Recent completions/failures today
echo -e "\n=== TODAY'S JOB HISTORY ==="
sacct -u $USER --format=JobID,JobName%-30,State,ExitCode,Elapsed,End -S $(date +%Y-%m-%d) 2>/dev/null | tail -15

# Check for preempted jobs that need resuming
echo -e "\n=== PREEMPTED/FAILED TODAY ==="
sacct -u $USER --format=JobID,JobName%-30,State -S $(date +%Y-%m-%d) 2>/dev/null | grep -E "PREEMPTED|FAILED|TIMEOUT" | head -10
```

---

## 4. Check Planning Files

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

# Check for existing planning files
echo "=== PLANNING FILES ==="
ls -la CLAUDE.md CLAUDE_SESSION.md TODO.md PR.md 2>/dev/null

# Check CLAUDE/ folder
if [ -d "CLAUDE" ]; then
    echo -e "\n=== CLAUDE/ FOLDER ==="
    ls -la CLAUDE/
fi

# Recent specstory entries
echo -e "\n=== RECENT SPECSTORY ==="
ls -lt .specstory/history/*.md 2>/dev/null | head -5

# Check for incomplete items in CLAUDE.md
if [ -f "CLAUDE.md" ]; then
    echo -e "\n=== INCOMPLETE ITEMS IN CLAUDE.md ==="
    grep -E "^\s*-\s*\[ \]" CLAUDE.md 2>/dev/null | head -10
fi
```

---

## 5. System Health Check

```bash
# Disk space
echo "=== DISK USAGE ==="
df -h / /tmp 2>/dev/null | grep -v "^Filesystem"

# GPU status (if applicable)
echo -e "\n=== GPU STATUS ==="
nvidia-smi --query-gpu=gpu_name,memory.used,memory.total,utilization.gpu --format=csv 2>/dev/null || echo "No GPU or nvidia-smi unavailable"

# Long-running processes
echo -e "\n=== LONG-RUNNING PROCESSES ==="
ps aux --sort=-%cpu | grep -E "python|node" | grep -v "cursor\|code\|grep" | head -5
```

---

## 6. Generate Handover (If Needed)

If there's significant uncommitted work or WIP, generate a handover. Use the key format from `handover.md`:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

# Generate handover key
BRANCH=$(git branch --show-current 2>/dev/null || echo "none")
HO_KEY="HO-$(date +%Y%m%d)-EOD-$(echo "${BRANCH}$(date +%s)" | md5sum | cut -c1-4)"

# Create CLAUDE directory if needed
mkdir -p CLAUDE

echo "Handover Key: $HO_KEY"
echo "Handover File: CLAUDE/${HO_KEY}.md"
```

### Handover File Template

Create `CLAUDE/$HO_KEY.md` with:

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# End of Day Handover

**Handover Key:** [HO_KEY]
**Date:** [today's date]
**Branch:** [current branch]
**Session focus:** [one-line summary of day's work]

---

## Day Summary
- Commits made: [count]
- Files changed: [list key files]
- Features touched: [brief description]

## Outstanding Work
### Uncommitted Changes
- [list files with brief description]

### Stashes
- [list stashes if any]

### WIP Branches
- [branches with uncommitted work]

## Overnight Jobs
| Job ID | Name | Status | Time Remaining |
|--------|------|--------|----------------|

## Tomorrow's Priorities
1. [ ] First priority
2. [ ] Second priority
3. [ ] Third priority

## Blockers / Risks
- [any overnight concerns]

## Startup Prompt (copy to new session)
```
**Handover Key:** [HO_KEY]
**Continue from:** End of day [date]

**Branch:** `[branch]`
**Repo:** `[repo path]`

**Read first:**
- `CLAUDE/[HO_KEY].md` (this handover)
- `CLAUDE.md` (if exists)

**State:**
- [Uncommitted work summary]
- [Jobs running overnight]

**First action:** [what to check/do first]
```
```

---

## 7. Update CLAUDE.md

If CLAUDE.md exists, update it with today's progress:

```markdown
## End of Day [date]
- Completed: [list completed items]
- Pending: [list pending items]
- Handover: `CLAUDE/[HO_KEY].md`
```

If CLAUDE.md doesn't exist but there's significant WIP, create one:

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# CLAUDE.md

## Current Work
- Branch: `[branch]`
- Focus: [what you're working on]

## End of Day [date]
- [summary of state]
- Handover: `CLAUDE/[HO_KEY].md`
```

---

## Output Format

Provide a concise end-of-day summary:

```
## End of Day Summary

### Today's Work
- Commits: 5 commits on `feat/something`
- Key changes: [brief list]
- Tests: [pass/fail status]

### Outstanding
- Uncommitted: 3 files (src/foo.py, tests/test_foo.py, config.yaml)
- Stashes: 1 (WIP: experimental feature)
- Merge: None in progress

### Overnight Jobs
| Job ID | Name | Est. Completion |
|--------|------|-----------------|
| 12345  | training-run | ~3am |
| 12346  | data-prep | ~11pm |

### Handover
- Key: HO-20260106-EOD-a1b2
- File: CLAUDE/HO-20260106-EOD-a1b2.md

### Tomorrow
1. [ ] Check overnight job results
2. [ ] Commit pending changes
3. [ ] Continue with [next task]

### Startup Prompt
[copy-paste block for tomorrow]
```

---

## Quick Reference: Overnight Checklist

```
┌─────────────────────────────────────────────────────────┐
│                  END OF DAY CHECKLIST                   │
├─────────────────────────────────────────────────────────┤
│ ✓ Reviewed uncommitted changes                         │
│ ✓ No merge conflicts left unresolved                   │
│ ✓ Stashes documented (or applied/dropped)              │
│ ✓ Overnight jobs look healthy (resources, time limits) │
│ ✓ CLAUDE.md updated with current state                 │
│ ✓ Handover created if significant WIP                  │
│ ✓ Tomorrow's first action is clear                     │
├─────────────────────────────────────────────────────────┤
│                  OVERNIGHT CONCERNS                     │
├─────────────────────────────────────────────────────────┤
│ ? Jobs might get preempted (check priority)            │
│ ? Disk might fill (large outputs expected?)            │
│ ? Time limits adequate for overnight run?              │
│ ? Checkpointing enabled for long runs?                 │
└─────────────────────────────────────────────────────────┘
```

---

## Decision Points

### When to Create Handover

| Situation | Action |
|-----------|--------|
| Uncommitted work exists | Create handover |
| Complex WIP spanning multiple files | Create handover |
| Overnight jobs running | Create handover (document expectations) |
| Clean state, nothing pending | Skip handover, just update CLAUDE.md |
| Continuing same work tomorrow | Update existing handover |

### When to Commit Before Leaving

**Don't commit automatically** - but suggest if:
- Work is at a logical stopping point
- Tests pass
- User explicitly wants to commit

Ask: "Should I help commit these changes before wrapping up, or leave them for tomorrow?"

---

## Always End With

1. **Handover key** (prominently displayed)
2. **Startup prompt** (copy-paste ready)
3. **Follow-up question** based on situation:

| Situation | Question |
|-----------|----------|
| Uncommitted changes | "Want to commit these before leaving, or keep as WIP?" |
| Overnight jobs running | "Want me to set up monitoring or alerts for these jobs?" |
| Clean state | "Anything else to wrap up before end of day?" |
| Missing context | "What were you working on today that I should capture?" |

**Default:** "Ready to wrap up. Anything else before end of day?"

---

## Related Commands

| Need | Command |
|------|---------|
| Commit changes | → **git-manager** |
| Detailed job management | → **sweep-manager** |
| Full status check | → **update** |
| Resume tomorrow | → **continue** or **agentic-continue** |
| Detailed handover | → **handover** |




