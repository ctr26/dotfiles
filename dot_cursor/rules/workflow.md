---
tag: WORKFLOW
---
# Workflow Patterns

Patterns extracted from command files that apply across workflows.

---

## Git Workflow

### Cherry-Pick First
- **Prefer cherry-picking commits** over copying files
- Preserves git history and authorship
- Makes PRs easier to review
- Fall back to file copy only when commits have mixed concerns

### Use Worktrees, Not Clones
- Worktrees share git objects (efficient, less disk space)
- Each worktree gets its own `CLAUDE.md` (isolated context per feature)
- Symlink shared resources (`.env`, cache, venv) but keep CLAUDE.md local
- Clean up with `git worktree remove` when done

---

## Context Management

### Worktree CLAUDE.md Isolation
- Each worktree has its own `CLAUDE.md` in the worktree root
- Do NOT symlink from main repo
- Keeps session context isolated per feature
- Delete when feature is merged

### Handover Keys
- Generate unique handover key: `HO-{YYYYMMDD}-{HHMM}-{hash}`
- Store in CLAUDE.md header for session tracking
- Next agent verifies key matches when resuming

---

## Execution Style

### Low-Interaction, High-Efficacy
- Do the obvious safe thing without asking
- Ask only when a real fork in the road exists
- Execute obvious steps once spec + tests are clear
- Don't ask for permission on every small decision

### Validation Gates Before Coding
- Run validation/TDD gates before making changes
- Know which test/validator proves success
- Include validation commands in plan AND final report
- Bug fix → write failing test first
- Feature → describe acceptance tests first

---

## ML / Training

### FAVOR RESUMES OVER RESTARTS
- **Never restart a sweep that has progress** unless fatal config error
- Preempted runs should be RESUMED, not restarted
- Check for existing checkpoints before any action
- Each epoch is valuable compute time

### Checkpoint Verification (Before Resume)
Before resuming any training run, verify:

```bash
# Check checkpoint exists and is recent
ls -la outputs/*/checkpoints/ 2>/dev/null | tail -5
# Verify WandB run ID matches
grep -r "wandb_run_id" outputs/*/config.yaml 2>/dev/null
```

| Check | Command | Fail Action |
|-------|---------|-------------|
| Checkpoint exists | `ls outputs/*/checkpoints/*.pt` | Don't resume, investigate |
| Not corrupted | `python -c "import torch; torch.load('ckpt.pt')"` | Restore from backup |
| Config matches | Compare `config.yaml` with intended config | Fix config or restart |
| WandB run exists | Check WandB UI for run status | Resume to same run ID |

### FAST COMPLETION = RED FLAG
- Runs finishing in <2 hours almost always indicate failure
- Training takes days, not hours
- Quick completion means crash/config error
- Always check logs for actual epoch count

### Cross-Reference WandB with Slurm
- Verify consistency between WandB state and Slurm state
- Detect zombie agents (WandB running, no Slurm job)
- Check for stale heartbeats (>30 min)

### Always Include WandB URLs
- Every sweep must have its WandB URL in reports
- Format: `[sweep_id](https://wandb.ai/entity/project/sweeps/sweep_id)`
- Include in ACTIVE_SWEEPS.md AND chat responses

### Reproducibility: Seed Logging
- **Always log random seeds** to WandB config
- Set seeds for: PyTorch, NumPy, Python random, CUDA
- Log package versions in config
- Store full config in WandB for experiment recreation

### OOM Prevention & Recovery

When hitting CUDA OOM errors, apply fixes in this order:

| Priority | Action | Trade-off |
|----------|--------|-----------|
| 1 | Reduce batch size by 50% | Slower training, adjust LR |
| 2 | Enable gradient checkpointing | ~20% slower, major memory savings |
| 3 | Use mixed precision (fp16/bf16) | Minor precision loss, 2x memory savings |
| 4 | Increase gradient accumulation | Same effective batch, slower step |
| 5 | Reduce sequence length / image size | May affect model quality |

**Batch size reduction formula:**
```
new_batch = old_batch // 2
new_lr = old_lr * (new_batch / old_batch)  # Linear scaling
grad_accum = old_batch // new_batch        # Maintain effective batch
```

**Prevention checklist before launch:**
- [ ] Estimate GPU memory: `model_params * 4 * 3` bytes (fp32 + grads + optimizer)
- [ ] Add 20% headroom for activations
- [ ] Test with 1 batch before full run
- [ ] Log `torch.cuda.max_memory_allocated()` to WandB

---

## Agent Handover Flow

The standard workflow for task handoff between agents:

```
Handover → New Agent → Plan Mode → ask_question → Plan UI Approval → Deploy
```

### Stages

| Stage | Description |
|-------|-------------|
| **1. Handover** | Create HO-*.md with startup prompt, update CLAUDE.md index |
| **2. New Agent** | User opens fresh chat, pastes startup prompt with handover key |
| **3. Plan Mode** | Agent gathers context, produces plan via `create_plan` tool |
| **4. Iterate** | Use `ask_question` for ALL decisions with discrete options |
| **5. Approval** | Wait for explicit plan UI approval (NOT "yes" or "sounds good") |
| **6. Deploy** | Execute plan steps, report progress |
| **7. Questions** | Use `ask_question` for any mid-execution decisions |

### Key Invariants

1. **Never interpret conversational affirmatives as plan approval**
   - "yes", "sounds good", "go ahead" → NOT plan approval
   - Only the explicit plan UI action exits planning mode

2. **Always use ask_question for decisions**
   - See #ASK-QUESTION for enforcement table

3. **Handover at natural boundaries**
   - After 15+ message exchanges
   - Before major context switches
   - When context confusion occurs

### Handover File Archival

Handover files older than 7 days should be archived:

```bash
find CLAUDE -name "HO-*.md" -mtime +7 -exec mv {} CLAUDE/archive/ \;
```




