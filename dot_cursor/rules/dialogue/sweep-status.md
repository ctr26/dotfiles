---
tag: DIALOGUE-SWEEP
scope: global
---
# Sweep Status Dialogue Template

ML experiment health check. Digest format from @ml/sweep command patterns.

---

## When to Use

- Quick sweep check-in
- Status updates in chat
- Before starting new experiments
- Debugging training issues

---

## Gather

```bash
echo "=== Sweep Status ==="

# Running jobs
echo -e "\n--- Slurm Jobs ---"
squeue -u $USER --format="%.10i %.25j %.8T %.10M %.6D" 2>/dev/null | head -10

# Recent failures/preemptions
echo -e "\n--- Issues (24h) ---"
sacct -u $USER --format=JobID,JobName%20,State,ExitCode \
  -S $(date -d '1 day ago' +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d) 2>/dev/null \
  | grep -E "PREEMPT|FAILED|TIMEOUT|OUT_OF_ME" | head -10

# Epoch/step for running jobs
echo -e "\n--- Training Progress ---"
for j in $(squeue -u $USER -h -o "%i" 2>/dev/null | head -5); do
  base=$(echo $j | cut -d'_' -f1)
  task=$(echo $j | cut -d'_' -f2)
  for prefix in run sweep; do
    log="logs/${prefix}_${base}_${task}.out"
    [ -f "$log" ] || continue
    epoch=$(tail -50 "$log" 2>/dev/null | grep -oP "'epoch':\s*\K[0-9.]+" | tail -1)
    step=$(tail -50 "$log" 2>/dev/null | grep -oP "'global_step':\s*\K[0-9]+" | tail -1)
    echo "Job $j: epoch=${epoch:-?} step=${step:-?}"
    break
  done
done

# Sweep IDs with WandB info
echo -e "\n--- Active Sweeps ---"
WANDB_ENTITY=${WANDB_ENTITY:-$(grep -oP 'entity:\s*\K\S+' wandb/settings 2>/dev/null)}
WANDB_PROJECT=${WANDB_PROJECT:-$(grep -oP 'project:\s*\K\S+' wandb/settings 2>/dev/null)}
grep -h "Sweep ID:" logs/*.out 2>/dev/null | sort -u | while read line; do
  sweep_id=$(echo "$line" | grep -oP 'Sweep ID:\s*\K\S+')
  echo "$sweep_id → https://wandb.ai/$WANDB_ENTITY/$WANDB_PROJECT/sweeps/$sweep_id"
done | head -5

# Checkpoint progress
echo -e "\n--- Top Checkpoints ---"
for dir in outputs/*/; do
  latest=$(ls -d ${dir}checkpoint-* 2>/dev/null | sort -t'-' -k2 -n | tail -1)
  [ -n "$latest" ] || continue
  step=$(echo "$latest" | grep -oP 'checkpoint-\K[0-9]+')
  echo "$(basename "$dir"): step-$step"
done | sort -t: -k2 -rn | head -5
```

---

## Output Format

```markdown
## Sweep Status

| Sweep | Jobs | Best Epoch | Progress | Health | WandB |
|-------|------|------------|----------|--------|-------|
| xyz123 | 3/8 | 2341 | 47% | ✅ OK | [link](url) |
| abc456 | 2/4 | 800 | 16% | ⚠️ 1 preempted | [link](url) |

### Running Jobs
| Job ID | Run | Epoch | Step | Runtime | Status |
|--------|-----|-------|------|---------|--------|
| 12345_0 | run-abc | 2341 | 54000 | 4:23:15 | ✅ Running |
| 12345_1 | run-def | 1200 | 28000 | 2:15:30 | ✅ Running |

### Issues (Last 24h)
| Job | Type | Resumable | Checkpoint | Action |
|-----|------|-----------|------------|--------|
| 12346_0 | PREEMPTED | ✅ Yes | step-45000 | Resume |
| 12347_0 | OOM | ✅ Yes* | step-30000 | Reduce batch |

### Recommended Actions
1. Resume preempted job 12346_0
2. Check OOM run - reduce batch size
```

---

## Health Indicators

| Symbol | Meaning |
|--------|---------|
| ✅ | Healthy, making progress |
| ⚠️ | Has issues but recoverable |
| ❌ | Failed, needs attention |
| 🚨 | Critical - likely broken (short runtime) |

---

## Red Flags

| Signal | Meaning |
|--------|---------|
| Runtime < 2h | Almost certainly failed early |
| Epoch = 0 | Config error, never started training |
| No checkpoints | Nothing saved, restart required |
| Loss = NaN | Diverged, needs LR/batch adjustment |

---

## Fallbacks

| Missing | Show Instead |
|---------|--------------|
| No Slurm | "Not on HPC cluster" |
| No jobs running | "No active jobs" |
| No WandB config | "WandB entity/project not configured" |
| No sweeps found | "No sweep IDs in logs" |

---

## Follow-Up

| Situation | Question |
|-----------|----------|
| Has preempted jobs | "Resume the preempted runs?" |
| Has failures | "Check error logs for [job]?" |
| All healthy | "Any sweep you want details on?" |
| No jobs | "Launch a new sweep?" |

---

## Related

| Need | Use Instead |
|------|-------------|
| Full sweep management | → @ml/sweep |
| General status check | → @update |
| Resume specific run | → `make run SWEEP=x RUN=y` |

