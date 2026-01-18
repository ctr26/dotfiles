# Audit Command

Invoke a committee of agents to review cursor config and produce a weighted verdict.

---

## Committee Members

| Agent | Weight | Lens |
|-------|--------|------|
| ml-scientist | 1.0 | Fail-fast, reproducibility, rapid iteration |
| ml-engineer | 1.0 | HPC/Slurm, training stability, resource efficiency |
| rse | 1.0 | DRY, maintainability, DX, git workflow |
| engineering | 1.0 | Production patterns, scalability, error boundaries |

---

## Scoring System

| Verdict | Score | Meaning |
|---------|-------|---------|
| PASS | 1.0 | No issues found |
| PASS_WITH_NOTES | 0.75 | Minor issues, actionable |
| CONDITIONAL | 0.5 | Significant issues, needs follow-up |
| FAIL | 0.0 | Blocking issues |

**Threshold:** Weighted average >= 0.6 = Committee PASS

---

## Workflow

### 1. Gather Config Files

```bash
find ~/.cursor/rules -name "*.md" -o -name "*.mdc" 2>/dev/null | wc -l
find ~/.cursor/commands -name "*.md" 2>/dev/null | wc -l
find ~/.cursor/agents -name "*.mdc" 2>/dev/null | wc -l
```

### 2. Apply Each Agent Lens

For each agent, review config files through their specific lens:

**ML Scientist lens:**
- Is fail-fast philosophy enforced?
- Are seeds/reproducibility requirements present?
- Is over-engineering avoided?

**ML Engineer lens:**
- Are HPC/Slurm safeguards complete?
- Is resource management documented?
- Are training stability patterns present?

**RSE lens:**
- Is content DRY (no duplication)?
- Are cross-references clear?
- Is cognitive load minimized?

**Engineering lens:**
- Are error boundaries appropriate?
- Are production patterns sound?
- Is scalability considered?

### 3. Collect Verdicts

Each agent produces:
- Strong points (what's working)
- Issues (what needs attention)
- Verdict (PASS | PASS_WITH_NOTES | CONDITIONAL | FAIL)

### 4. Calculate Committee Decision

```
score = (ml_scientist * 1.0 + ml_engineer * 1.0 + rse * 1.0 + engineering * 1.0) / 4
overall = "PASS" if score >= 0.6 else "FAIL"
```

---

## Output Template

Generate report at `CLAUDE/audit-{date}.md`:

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# Audit Results - {description}

**Date:** YYYY-MM-DD
**Reviewed by:** ml-scientist, ml-engineer, rse, engineering

---

## ML Scientist Review

**Lens:** Research-first, hypothesis-driven, reproducibility

### Strong Points
- [list]

### Issues
| Issue | Severity | Recommendation |
|-------|----------|----------------|

### Verdict: [PASS | PASS_WITH_NOTES | CONDITIONAL | FAIL]

---

## ML Engineer Review
[same format]

## RSE Review
[same format]

## Engineering Review
[same format]

---

## Action Items

1. **[HIGH]** [description]
2. **[MEDIUM]** [description]
3. **[LOW]** [description]

---

## Summary

| Agent | Verdict | Score |
|-------|---------|-------|
| ML Scientist | X | 0.X |
| ML Engineer | X | 0.X |
| RSE | X | 0.X |
| Engineering | X | 0.X |

**Weighted Average:** 0.XX
**Overall:** [PASS | FAIL]
```

---

## Example Follow-Up

"The audit found 3 medium-priority issues. Would you like to address them now, or schedule for later?"

---

## Related Commands

| Command | Use When |
|---------|----------|
| **config/review** | Deeper review with ask_question prompts |
| **update** | Quick status check |
| **session/handover** | Document findings for next session |

