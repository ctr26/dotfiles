# Update Assistant

Check on everything running and give a comprehensive status report.

---

## Workflow

Run each section, skip what doesn't apply, then summarize with action items.

---

## Checks

### Disk
```bash
df -h / /tmp 2>/dev/null | grep -v "^Filesystem"
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
du -sh "$REPO_ROOT/outputs" "$REPO_ROOT/wandb" "$REPO_ROOT/logs" 2>/dev/null | sort -hr
```

### Git
```bash
git status --short --branch
git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null
git log --oneline -5
git stash list
```

### Slurm Jobs
```bash
squeue -u $USER --format="%.10i %.20j %.8T %.10M %.9l" 2>/dev/null
sacct -u $USER --format=JobID,JobName%-20,State,ExitCode -S $(date -d '3 days ago' +%Y-%m-%d 2>/dev/null || date -v-3d +%Y-%m-%d) 2>/dev/null | tail -15
```

### Project Markers
```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
ls "$REPO_ROOT/ACTIVE_SWEEPS.md" "$REPO_ROOT/CLAUDE.md" "$REPO_ROOT/TODO.md" 2>/dev/null
```

### Background Processes
```bash
pgrep -af python | grep -v "cursor\|code" | head -5
nvidia-smi --query-gpu=memory.used,memory.total,utilization.gpu --format=csv 2>/dev/null
tmux list-sessions 2>/dev/null
```

### Docker (if applicable)
```bash
docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null
```

---

## Output Format

```
## Status Update

### Disk: 78% (outputs: 45G, wandb: 12G)

### Git: `feat/something` (3 ahead), 2 uncommitted files

### Jobs
- Running: 2 (sweep-bayes, data-prep)
- Preempted: 1 (job 12345)

### Training: 2 active sweeps, 47 checkpoints

### Action Items
- [ ] Resume preempted job 12345
- [ ] Commit staged changes
```

Focus on actionable items.

---

## Summary Pattern

After gathering, state:
1. What's healthy vs needs attention
2. Top priority
3. Recommended next action

**Example:**
> "2 jobs running normally, 1 preempted. Git has 3 uncommitted files. Priority: resume the preempted job."

---

## Example Follow-Up

"What would you like to focus on? Resume jobs, commit changes, or dig into sweeps?"

---

## Related Templates

For focused status checks, see `~/.cursor/rules/dialogue/`:
- `morning-standup.md` - Start of day with overnight job check
- `sweep-status.md` - ML experiment health digest
