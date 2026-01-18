---
tag: DIALOGUE-MICRO
scope: global
---
# Micro Handover Dialogue Template

Quick context handover mid-session. For long chats or spawning a fresh agent.

---

## When to Use

- Chat getting long (15+ messages)
- Context window filling up
- Spawning a new agent to continue
- Quick save point before risky operation
- Switching focus within same session

---

## Gather

```bash
echo "=== Micro Handover ==="

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Current state
echo -e "\n--- Current State ---"
git branch --show-current
git status --short

# Recently modified files (last hour)
echo -e "\n--- Recently Touched ---"
find . -name "*.py" -o -name "*.md" -o -name "*.yaml" 2>/dev/null \
  | xargs ls -lt 2>/dev/null | head -10

# Git diff summary
echo -e "\n--- Changes Summary ---"
git diff --stat HEAD 2>/dev/null | tail -5

# Last 3 commits (if any new)
echo -e "\n--- Recent Commits ---"
git log --oneline -3 2>/dev/null
```

---

## Output Format

```markdown
## Micro Handover

**Branch:** `feat/x` | **Time:** 14:32

### Just Done
- Created `src/auth/handler.py` with JWT validation
- Updated `tests/test_auth.py` with new fixtures
- Fixed import in `src/main.py`

### In Progress
[Current task being worked on]

### Files Touched
- `src/auth/handler.py` (new)
- `tests/test_auth.py` (modified)
- `src/main.py` (modified)

### Next Step
[Immediate next action]

### Git Status
- 3 files modified
- Not committed
```

---

## Minimal Version

For very quick handovers:

```markdown
**Branch:** `feat/x`
**Done:** Added JWT handler, updated tests
**Next:** Wire up to routes
**Git:** 3 modified, uncommitted
```

---

## When Spawning New Agent

Include startup prompt:

```markdown
## Micro Handover

[...regular content...]

---

### Startup Prompt for New Agent

**Branch:** `feat/x`
**Context:** Working on JWT auth flow
**Just done:** Created handler, tests passing
**Next:** Wire handler to routes in `src/routes/auth.py`
**Files:** `src/auth/handler.py`, `src/routes/auth.py`

Start by reading the handler, then integrate into routes.
```

---

## Context to Include

| Always Include | Include If Relevant |
|----------------|---------------------|
| Branch name | Error being debugged |
| Files touched | Test results |
| Next step | Blocking issue |
| Git status | Uncommitted changes |

---

## Context to Skip

- Full file contents (just reference paths)
- Long command outputs
- Historical context (covered in CLAUDE.md)
- Explanations of what code does

---

## Fallbacks

| Missing | Show Instead |
|---------|--------------|
| No recent files | "No files touched yet" |
| No changes | "Clean working tree" |
| No clear next step | "Waiting for direction" |

---

## Follow-Up

| Situation | Question |
|-----------|----------|
| Spawning new agent | "Copy the startup prompt and open new chat" |
| Continuing same chat | "Ready to continue with [next step]?" |
| Unclear direction | "What should the next agent focus on?" |

---

## Related

| Need | Use Instead |
|------|-------------|
| Full session handover | → @session/handover |
| End of day | → @session/eod |
| Quick orientation | → #DIALOGUE-CATCHUP |
| Continue planning | → @session/continue |

