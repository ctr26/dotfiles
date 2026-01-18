# End of Day Assistant

Summarize today's work, check for loose ends, prepare handover, verify overnight jobs.

See #CONTEXT for environment setup.

---

## Mission

1. **Summarize** – commits, files changed
2. **Surface loose ends** – uncommitted work, stashes
3. **Check overnight jobs** – Slurm health
4. **Generate handover** – if significant WIP
5. **Startup prompt** – for tomorrow

---

## 1. Today's Work

```bash
git log --oneline --since="6am" | head -20
git branch --show-current
git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:relative)' refs/heads/ | head -5
```

---

## 2. Outstanding Work

```bash
git status --short
git stash list
git ls-files --others --exclude-standard | head -10
[ -f ".git/MERGE_HEAD" ] && echo "MERGE IN PROGRESS"
```

---

## 3. Overnight Jobs

```bash
squeue -u $USER --format="%.10i %.30j %.8T %.10M %.12l" 2>/dev/null | head -15
sacct -u $USER --format=JobID,JobName%-20,State -S $(date +%Y-%m-%d) 2>/dev/null | grep -E "PREEMPTED|FAILED" | head -5
```

---

## 4. System Health

```bash
df -h / /tmp 2>/dev/null | grep -v "^Filesystem"
nvidia-smi --query-gpu=memory.used,memory.total --format=csv 2>/dev/null || echo "No GPU"
```

---

## 5. Generate Handover

If significant WIP exists:

```bash
BRANCH=$(git branch --show-current 2>/dev/null || echo "none")
HO_KEY="HO-$(date +%Y%m%d)-EOD-$(echo "${BRANCH}$(date +%s)" | md5sum | cut -c1-4)"
mkdir -p CLAUDE
echo "Handover: CLAUDE/${HO_KEY}.md"
```

### Handover Template

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# End of Day Handover

**Key:** [HO_KEY] | **Date:** [date] | **Branch:** [branch]

## Day Summary
- Commits: [count]
- Key changes: [list]

## Outstanding
- Uncommitted: [files]
- Stashes: [list]

## Overnight Jobs
| Job ID | Name | Status |
|--------|------|--------|

## Tomorrow
1. [ ] First priority
2. [ ] Second priority

## Startup Prompt
**Handover Key:** [HO_KEY]
**Branch:** `[branch]`
**Read:** `CLAUDE/[HO_KEY].md`
**First action:** [what to do]
```

---

## Output Format

```
## End of Day Summary

### Today: 5 commits on `feat/something`
### Outstanding: 3 uncommitted files, 1 stash
### Jobs: 2 running (training-run ~3am, data-prep ~11pm)
### Handover: HO-20260106-EOD-a1b2

### Tomorrow
1. Check overnight results
2. Commit pending changes

### Startup Prompt
[copy-paste block]
```

---

## Overnight Checklist

```
✓ Uncommitted changes reviewed
✓ No unresolved merge conflicts
✓ Stashes documented
✓ Overnight jobs healthy
✓ CLAUDE.md updated
✓ Handover created if needed
```

---

## When to Create Handover

| Situation | Action |
|-----------|--------|
| Uncommitted work | Create handover |
| Overnight jobs | Create handover |
| Clean state | Skip, just update CLAUDE.md |

---

## Example Follow-Up

"Ready to wrap up. Want to commit before leaving, or keep as WIP?"
