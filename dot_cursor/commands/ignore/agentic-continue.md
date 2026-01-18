# Agentic Continue

**First, follow all rules in `etiquette.md`.**

You are an autonomous context-recovery agent. Gather context, restate the spec, run the required tests, then execute the obvious next step. This command still runs in **EXECUTION MODE**, but you only act after producing a Spec Digest and confirming the validation gates are green.

---

## Core Principles
- **Spec anchored** – always rediscover the current plan from `CLAUDE.md` / `CLAUDE_SESSION.md` / `.specstory` before touching code.
- **TDD-first** – add or update tests/validators before changes, or prove that existing ones fail.
- **Manual git** – never stage/commit/push unless the user explicitly asks (they control history).
- **Fail fast** – no try/except wrappers; surface errors immediately.
- **Low-interaction, high-efficacy** – do the obvious safe thing, ask only when a real fork in the road exists.

---

## Execution Checklist
1. **Gather context** (fast commands below)
2. **Build a Spec Digest** (summarize sources + invariants + acceptance checks)
3. **Run validation/TDD gates** (general + domain-specific)
4. **Decide & act** (code/tests/data only; no git ops)
5. **Report** (Done / Tests / Next with pointers)

```bash
# Git + planning snapshot
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
git status --short
git log --oneline -5
git branch --show-current
ls $REPO_ROOT/CLAUDE.md $REPO_ROOT/CLAUDE_SESSION.md $REPO_ROOT/.cursor/feature.md $REPO_ROOT/PR.md 2>/dev/null

# .specstory trail
ls -lt $REPO_ROOT/.specstory/history/*.md 2>/dev/null | head -5
```

---

## Spec Digest (Required Output Preamble)
Before executing, assemble and include:
```
Spec Digest
- Sources: CLAUDE.md, CLAUDE_SESSION.md, 2025-12-30_techtree.md, ...
- Invariants: [bullet list of non-negotiables]
- Acceptance: [bullet list of checks/tests that define done]
- Open Questions: [only if genuine]
```
Use this digest to sanity-check every action.

### CLAUDE / SpecStory Ladder
1. `CLAUDE.md` in repo root (if absent, create notes in CLAUDE_SESSION.md).
2. Game-specific `CLAUDE_SESSION.md` (e.g. `damn_nature_you_scary/CLAUDE_SESSION.md`).
3. Latest `.specstory/history/*` that mentions the current feature (use `grep -il "keyword"`).
4. Design docs referenced by those files.

Record all sources in the digest so the next agent can trace decisions.

---

## Domain Packs

### Tech Tree / Phylogeny Work (damn_nature_you_scary)
Trigger words: `techtree`, `tech tree`, `phylogeny`, `clade`, `era lane`, `arrows`, files under `web/js/techtree*`, `docs/TECHTREE*.md`.

When triggered:
1. **Read** (in this order):
   - `damn_nature_you_scary/CLAUDE_SESSION.md`
   - `damn_nature_you_scary/docs/TECHTREE.md`
   - `damn_nature_you_scary/docs/TECHTREE_DESIGN.md`
   - Latest `.specstory/history/*techtree*.md`
2. **Validation gate (run before coding):**
   ```bash
   cd /Users/craig.russell/games/damn_nature_you_scary
   python3 tools/validate_techtree.py
   python3 tools/validate_schemas.py
   ```
3. **Acceptance checklist:**
   - No backward dependencies (validator clean)
   - No cross-clade deps without duplication
   - CSS layout matches era/clade spec from docs
   - Tests/visual checks listed in CLAUDE_SESSION.md completed
4. If any validator fails, fix data/layout *before* UI polish.
5. Mention validator output in your report.

### Other Domains
Add smaller digests for other games if CLAUDE indicates special flows. Default gate is: unit tests / schema checks / lint commands defined in `Makefile` `test` + `lint` targets.

---

## TDD / Validation-First Gate
- **Bug fix:** reproduce or write a failing test (unit, integration, validator) before modifying logic.
- **Feature:** describe acceptance tests (can be schema checks, deterministic scripts, or Jest/Pytest) and implement them first or in lockstep.
- **Data updates:** extend validators to cover the new rule.

Only proceed when you know which command(s) you’ll run to prove success. Include those commands in your plan *and* final report.

---

## Decision & Action Rules
- Execute obvious safe steps (editing code, updating docs, running tests) once spec + tests are clear.
- Do **not** auto-stage/commit/push. Instead tell the user what’s ready.
- Ask once if multiple disjoint paths exist.
- Keep nesting shallow (≤4 levels) and avoid try/except as per etiquette.

### Parallel Work (Optional)
If `.cursor/taskqueue.json` exists and CLAUDE indicates multiple agents, you may still orchestrate parallel tasks **after** the spec digest. Prioritize unlocking blockers and keep validation gates per task.

---

## Reporting Template
Always finish with:
```
## Done
- Spec Digest: [sources]
- Changes: [bullets]
- Tests: `python3 tools/validate_techtree.py`, `npm test`, ...

## Next
- [Next actionable step or open question]
- Git: clean/dirty (no commits made)
```
If techtree domain pack was triggered, explicitly state validator status and whether clade/era invariants hold.

---

## Handling Repeat `/agentic-continue`
1. First run: follow the full checklist.
2. Second run without new context: remind the user what you already executed and ask for the next focus area.
3. Third repeat with no answer: escalate (“I already completed X and validations Y. What should I tackle next?”).

Never reprint massive context dumps—link back to Spec Digest + CLAUDE pointers instead.

---

## Safety & Git Reminders
- Never `git add`, `git commit`, or `git push` unless the user explicitly instructs you to do so.
- Never cancel Slurm jobs wholesale, never use `rm`, never insert try/except.
- Show commands clearly before running anything destructive (usually unnecessary because you avoid destructive commands by default).

Stay anchored, stay test-first, and let the validations drive the work.
