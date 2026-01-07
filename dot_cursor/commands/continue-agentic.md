# Agentic Continue

Autonomous context-recovery agent. **EXECUTION MODE**: gather context, restate spec, run tests, execute the obvious next step.

See `~/.cursor/rules/context-gathering.md` for environment setup.

---

## Core Principles

- **Spec anchored** – rediscover plan from CLAUDE.md/.specstory before coding
- **TDD-first** – add/update tests before changes
- **Manual git** – never stage/commit/push unless explicitly asked
- **Fail fast** – no try/except; surface errors
- **Low-interaction** – do the obvious safe thing, ask only at real forks

---

## Execution Checklist

1. **Gather context** (fast commands)
2. **Build Spec Digest** (sources + invariants + acceptance)
3. **Run validation gates**
4. **Decide & act** (code/tests only; no git)
5. **Report** (Done / Tests / Next)

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
git status --short
git log --oneline -5
ls $REPO_ROOT/CLAUDE.md $REPO_ROOT/CLAUDE_SESSION.md 2>/dev/null
ls -lt $REPO_ROOT/.specstory/history/*.md 2>/dev/null | head -5
```

---

## Spec Digest (Required Preamble)

```
Spec Digest
- Sources: CLAUDE.md, ...
- Invariants: [non-negotiables]
- Acceptance: [tests that define done]
- Open Questions: [only if genuine]
```

---

## TDD Gate

- **Bug fix:** write failing test before modifying logic
- **Feature:** describe acceptance tests first
- **Data update:** extend validators

Only proceed when you know which command proves success.

---

## Action Rules

- Execute obvious safe steps once spec + tests are clear
- Do NOT auto-commit/push – tell user what's ready
- Ask once if multiple disjoint paths exist
- Keep nesting ≤4 levels, no try/except

---

## Reporting Template

```
## Done
- Sources: [list]
- Changes: [bullets]
- Tests: `pytest`, `make test`, ...

## Next
- [Next step or question]
- Git: clean/dirty (no commits made)
```

---

## Handling Repeats

1. First run: full checklist
2. Second run: remind what you did, ask for next focus
3. Third: escalate ("I completed X. What next?")

Don't reprint massive context – link back to Spec Digest.

---

## Safety

- Never git add/commit/push without explicit request
- Never cancel Slurm jobs wholesale
- Never use `rm`
- Never insert try/except
