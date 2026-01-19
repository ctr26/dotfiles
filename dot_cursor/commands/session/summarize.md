# Summarize Session

Generate a copy-paste startup prompt for another agent. No file creation—output directly to chat.

See #CONTEXT for environment setup.

---

## When to Use

- Passing context to another agent (Slack, new Cursor tab)
- Handing off mid-session without persisting files
- Creating a portable context snapshot

---

## vs /session/handover

| summarize | handover |
|-----------|----------|
| Output to chat | Creates `CLAUDE/HO-*.md` |
| No persistence | Persistent file |
| Clipboard-ready | Key-referenced |
| Self-contained | Requires file access |

---

## Gather Context

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
BRANCH=$(git branch --show-current 2>/dev/null || echo "none")

echo "=== Summarize Session ==="
echo "Repo: $REPO_ROOT"
echo "Branch: $BRANCH"

# Recent commits
echo -e "\n--- Recent Commits ---"
git log --oneline -5 2>/dev/null || echo "(no commits)"

# Uncommitted changes
echo -e "\n--- Pending Changes ---"
git status --short 2>/dev/null || echo "(not a git repo)"

# CLAUDE.md context
echo -e "\n--- CLAUDE.md ---"
if [ -f "$REPO_ROOT/CLAUDE.md" ]; then
  head -20 "$REPO_ROOT/CLAUDE.md"
else
  echo "No CLAUDE.md"
fi

# Recent handover
echo -e "\n--- Latest Handover ---"
ls -t "$REPO_ROOT/CLAUDE/"*.md 2>/dev/null | head -1 | xargs cat 2>/dev/null | head -15 || echo "None"
```

---

## Output Template

Generate this block in a fenced code block for easy copy-paste:

~~~markdown
## Self-Contained Startup Prompt

**Branch:** `[branch]`
**Repo:** [/path/to/repo]
**Focus:** [one-line summary from CLAUDE.md or session]

### Context
[2-3 sentences describing current state and what's happening]

### Files to Read
- `[key/file.py]` - [why this file matters]
- `CLAUDE.md` - current state

### What Was Done
- [bullet list of completed work this session]

### What's Next
1. [First action with acceptance criteria]
2. [Second action]

### Commands to Run First
```bash
git status && cat CLAUDE.md
```
~~~

---

## Content Guidelines

| Section | What to Include |
|---------|-----------------|
| Focus | One line from CLAUDE.md or derive from session |
| Context | Branch state, uncommitted changes, blockers |
| Files to Read | 3-5 most relevant files for next steps |
| What Was Done | Only this session's work |
| What's Next | Actionable items with clear acceptance |
| Commands | Quick orientation commands |

---

## Keep It Portable

The output must be **self-contained**:

- No references to handover files (agent may not have access)
- No assumptions about context (fresh agent)
- Include enough detail to start immediately
- Fits in clipboard (~500 words max)

---

## Example Output

```markdown
## Self-Contained Startup Prompt

**Branch:** `feat/auth-flow`
**Repo:** /home/user/project/api
**Focus:** Implementing JWT refresh token logic

### Context
Added refresh token endpoint. Tests pass locally but CI fails on timeout.
Uncommitted: 2 files (tests/test_auth.py, src/auth/refresh.py).

### Files to Read
- `src/auth/refresh.py` - new refresh logic
- `tests/test_auth.py` - failing CI test
- `CLAUDE.md` - current state

### What Was Done
- Created RefreshTokenService class
- Added /api/v1/auth/refresh endpoint
- Wrote unit tests (5 passing locally)

### What's Next
1. Debug CI timeout - check test isolation
2. Add integration test for token rotation

### Commands to Run First
git status && pytest tests/test_auth.py -v
```

---

## Related Commands

| Need | Use Instead |
|------|-------------|
| Persist handover to file | → `/session/handover` |
| Full context recovery | → `/session/continue` |
| Quick orientation | → `/session/catch-up` |

