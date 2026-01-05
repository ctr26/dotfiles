# Safety Rules

## 🚨 NEVER Do These

| Action | Why | Instead |
|--------|-----|---------|
| `git push` | User controls remote | Ask permission, wait |
| `git commit` without ask | User decides timing | Only when explicitly asked |
| `scancel -u $USER` | Kills ALL jobs | Cancel specific job IDs only |
| `rm` anything | Data loss risk | `mv` to backup location |
| `sleep` in commands | Wastes time, can hang | Just wait for user |
| `find /` or unbounded scans | Hangs forever | Use bounded `head`, scoped paths |
| try/catch blocks | Hides errors | Let errors propagate (fail fast) |
| Deep nesting (>4 levels) | Unreadable | Extract to functions |

## Verification Checklists

### Before Committing
- [ ] User explicitly said "commit"
- [ ] Changes are staged and reviewed
- [ ] Commit message follows [tag] format
- [ ] One concern per commit

### Before Any Destructive Operation
- [ ] Showed what will happen first
- [ ] User approved the action
- [ ] Backup exists if needed
- [ ] Can be undone if wrong

### Before Slurm Operations
- [ ] Ran `squeue -u $USER` to see what's running
- [ ] Identified specific job IDs
- [ ] Not canceling jobs I didn't start

### Before Long-Running Commands
- [ ] Command is bounded (has head/tail/limit)
- [ ] Won't prompt for input
- [ ] Has timeout or will complete quickly

