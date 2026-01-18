# Morning Standup Dialogue Template

Start of day orientation. Complements `/session/eod` for end of day.

---

## When to Use

- First thing in the morning
- After overnight jobs have run
- Returning after days away
- Planning the day's work

---

## Gather

```bash
echo "=== Morning Standup ==="

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Yesterday's work
echo -e "\n--- Yesterday ---"
git log --oneline --since="yesterday 6am" --until="today 6am" 2>/dev/null | head -10
YESTERDAY_COMMITS=$(git log --oneline --since="yesterday 6am" --until="today 6am" 2>/dev/null | wc -l | tr -d ' ')
echo "Commits yesterday: $YESTERDAY_COMMITS"

# Current branch and state
echo -e "\n--- Current State ---"
git branch --show-current
git status --short
git stash list | head -3

# Overnight jobs (if on HPC)
echo -e "\n--- Overnight Jobs ---"
if command -v squeue &>/dev/null; then
  echo "Running:"
  squeue -u $USER --format="%.10i %.20j %.8T %.10M" 2>/dev/null | head -10
  
  echo -e "\nCompleted overnight:"
  sacct -u $USER --format=JobID,JobName%20,State,Elapsed,End \
    -S $(date -d 'yesterday 6pm' +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d) 2>/dev/null \
    | grep -E "COMPLETED|FAILED|PREEMPTED|TIMEOUT" | tail -15
else
  echo "Not on HPC cluster"
fi

# Background processes
echo -e "\n--- Background Processes ---"
pgrep -af python 2>/dev/null | grep -v "cursor\|code" | head -5
tmux list-sessions 2>/dev/null || echo "No tmux sessions"

# Today's priorities from CLAUDE.md
echo -e "\n--- Priorities ---"
if [ -f "$REPO_ROOT/CLAUDE.md" ]; then
  grep -E "^- \[ \]|^1\. \[ \]|^## Pending|^## Next|^## Today" "$REPO_ROOT/CLAUDE.md" 2>/dev/null | head -8
else
  echo "No CLAUDE.md - set priorities?"
fi

# Disk check
echo -e "\n--- Disk ---"
df -h / 2>/dev/null | tail -1
```

---

## Output Format

```markdown
## Morning Standup

**Date:** Monday, Jan 18, 2026
**Branch:** `feat/data-loader`

### Yesterday
- 5 commits on `feat/data-loader`
- Last: "abc123 [feat] add batch processing"
- Ended at epoch 3400

### Overnight Results
| Job | Status | Runtime | Result |
|-----|--------|---------|--------|
| training-run | ✅ COMPLETED | 8:45:00 | epoch 5000 |
| data-prep | ⚠️ PREEMPTED | 3:20:00 | resumable |

### Blockers
- None / [List blockers]

### Today's Priorities
1. [ ] Review overnight training results
2. [ ] Resume preempted job
3. [ ] [From CLAUDE.md pending items]

### System Health
- Disk: 45% used
- GPU: available
- 2 jobs running
```

---

## Priority Sources

Check these in order for today's priorities:

1. CLAUDE.md pending items (`- [ ]` checkboxes)
2. Overnight job failures requiring attention
3. Yesterday's incomplete work
4. Stashed changes to address
5. EOD handover from previous day

---

## Overnight Job Analysis

| Status | Meaning | Action |
|--------|---------|--------|
| COMPLETED | Finished successfully | Review results |
| PREEMPTED | Cluster preemption | Resume from checkpoint |
| TIMEOUT | Hit time limit | Resume or increase limit |
| FAILED | Error occurred | Check logs |
| RUNNING | Still going | Monitor progress |

---

## Fallbacks

| Missing | Show Instead |
|---------|--------------|
| No commits yesterday | "No commits yesterday" |
| No Slurm | "Local dev environment" |
| No CLAUDE.md | "No priorities set - what's the focus?" |
| No overnight jobs | "No overnight jobs ran" |

---

## Follow-Up

| Situation | Question |
|-----------|----------|
| Has overnight failures | "Check the failed job logs?" |
| Has preempted jobs | "Resume the preempted runs?" |
| Has pending priorities | "Start with [first priority]?" |
| Clean slate | "What's the focus for today?" |

---

## Related

| Need | Use Instead |
|------|-------------|
| End of day wrap-up | → `/session/eod` |
| Quick context recovery | → `catch-up` template |
| Sweep status | → `sweep-status` template |
| Full planning mode | → `/session/continue` |

