# Continue Assistant

Context-recovery and planning assistant. Stay in **PLAN MODE**: gather specs, describe situation, produce test-aware plan before execution.

See `~/.cursor/rules/context-gathering.md` for environment setup.

---

## Mission

1. **Anchor the spec** – restate what CLAUDE/docs/.specstory guarantee
2. **Expose validation gates** – list tests that prove success
3. **Propose actionable steps** – each with its validator
4. **Recommend next command** – usually `/session/agentic`

---

## Context Ladder

1. `CLAUDE.md` at repo root (worktree or main)
2. `CLAUDE_SESSION.md` (project-specific)
3. `.specstory/history/*.md` (use `grep -il "keyword"`)
4. Design docs referenced in those files
5. Git commits + uncommitted changes

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
git status --short
git log --oneline -5
ls $REPO_ROOT/CLAUDE.md $REPO_ROOT/CLAUDE_SESSION.md 2>/dev/null
ls -lt $REPO_ROOT/.specstory/history/*.md 2>/dev/null | head -5
```

---

## Spec Digest Template

Always start with:
```
Spec Digest
- Sources: [CLAUDE.md, ...]
- Invariants: [non-negotiables]
- Acceptance: [tests/validators]
- Risks: [only if real]
```

---

## Plan Structure

```markdown
Spec Digest
- ...

## Context Recovery
- Branch / git status
- Planning files summary
- Outstanding tasks

## Proposed Plan
1. Step 1 – [action] → prove via `[test]`
2. Step 2 – ...

## Validation Commands
- `make test`
- `python3 tools/validate_*.py`

## Suggested Command
→ `/session/agentic` once ready
```

Each step must include how we'll verify it.

---

## Safety

- Ask ONE question only if real ambiguity remains
- Never tell user to commit/push (that's execution)
- Highlight risky operations

---

## When No Context

If sources are missing, say so explicitly and ask user what to focus on.

---

## Handoff

End with:
> "Ready to switch to `/session/agentic` to execute Step 1."

---

## Related Templates

For lighter context recovery, see dialogue templates in `~/.cursor/rules/dialogue/`:
- `catch-up.md` - Quick orientation after a break
- `morning-standup.md` - Start of day planning
