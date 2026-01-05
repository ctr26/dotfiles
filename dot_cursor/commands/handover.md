# Handover Assistant

You summarize the current session into `CLAUDE.md`/`CLAUDE_SESSION.md` so the next agent can rebuild the feature from scratch. A good handover captures:
- **Spec Digest** (sources + invariants)
- **What changed** (files, data, design decisions)
- **Validation status** (tests/validators run, their output)
- **Next steps / blockers**
- **Pointers to chat history & design docs**
- **Startup prompt** the next agent can paste directly

---

## Generate Handover Key

Every handover needs a unique key for tracking session continuity. Generate one first:

```bash
# Generate handover key: HO-{YYYYMMDD}-{HHMM}-{4char-hash}
BRANCH=$(git branch --show-current 2>/dev/null || echo "none")
HO_KEY="HO-$(date +%Y%m%d-%H%M)-$(echo "${BRANCH}$(date +%s)" | md5sum | cut -c1-4)"
echo "Handover Key: $HO_KEY"
```

Store this key in:
1. **CLAUDE.md** header (for next agent to find)
2. **Your response** (for user to paste when starting new agent)

The next agent should verify the key matches when resuming work.

---

## Gather Context First
```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

# Detect worktree context
GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "$GIT_COMMON_DIR" ] && [ -n "$GIT_COMMON_DIR" ]; then
    MAIN_REPO=$(dirname "$GIT_COMMON_DIR")
    echo "=== WORKTREE DETECTED ==="
    echo "Worktree: $REPO_ROOT"
    echo "Main repo: $MAIN_REPO"
    echo "CLAUDE.md location: $REPO_ROOT/CLAUDE.md (worktree-local)"
else
    echo "Working in main repo: $REPO_ROOT"
fi

# Git + branch
printf "Branch: %s\n" "$(git branch --show-current)"
git status --short

git log --oneline --since="12 hours ago" | head -10

# Planning files (in current worktree or main repo)
ls CLAUDE.md CLAUDE_SESSION.md CLAUDE/ .cursor/feature.md PR.md TODO.md 2>/dev/null

# SpecStory trail
ls -lt .specstory/history/*.md 2>/dev/null | head -5

# Domain-specific docs for techtree work
ls damn_nature_you_scary/docs/TECHTREE*.md 2>/dev/null
```
Also capture validator/test outputs (e.g. `python3 tools/validate_techtree.py`). Include the command + success/failure text in the handover.

**Worktree note:** When in a worktree, CLAUDE.md stays in the worktree directory (not main repo). This keeps session context isolated per feature.

---

## CLAUDE.md Template (Required Sections)

**Location:** Create CLAUDE.md in the current working directory (`$REPO_ROOT`). When in a worktree, this is the worktree root - NOT the main repo.

All handovers must contain:

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# CLAUDE.md - Session Handover

**Last updated:** 2025-12-30 14:05
**Branch:** feature/xyz
**Worktree:** [worktree path if applicable, else "main repo"]
**Handover Key:** [HO_KEY from generation step]
**Session focus:** [one-line summary]

---

## Spec Digest
- **Sources:** CLAUDE_SESSION.md, docs/TECHTREE_DESIGN.md, 2025-12-30_techtree.md
- **Invariants:** [bullet list of non-negotiables]
- **Acceptance:** [tests/validators that constitute “done”]

## What Changed This Session
### Files Modified
- `path/to/file` – short description

### Commits Made
```
[hash] [message]
```
(If none, say so.)

## Validation Summary
| Command | Result | Notes |
|---------|--------|-------|
| `python3 tools/validate_techtree.py` | PASS | no backward deps |
| `make test` | FAIL | grid snapshot test pending |

## What's Pending ⏳
- [ ] Task / bug / follow-up with acceptance criteria

## Key Decisions
| Decision | Reason |
|----------|--------|

## Context for Next Session
- What to do first
- Known blockers or data dependencies
- Links to assets/specs

## Related Chat / Docs
| Date | File | Summary |
|------|------|---------|

## Startup Prompt (copy this to new agent)
```
**Handover Key:** [HO_KEY from generation step]
[See template below]
```
```

Every section above is mandatory. If something doesn’t apply, explicitly write “None”.

---

## Startup Prompt Template
```markdown
## Startup Prompt (copy this to new agent)

**Handover Key:** [HO_KEY from generation step]
**Continue working on:** [feature]

**Repo:** `/Users/craig.russell/games/damn_nature_you_scary`
**Worktree:** `/Users/craig.russell/games/damn_nature_you_scary/worktrees/feat-xyz` (if applicable)
**Branch:** `feature/xyz`
**Context file:** `[worktree or repo path]/CLAUDE.md`

**Read these first:**
- `[worktree or repo path]/CLAUDE.md`
- `[worktree or repo path]/CLAUDE_SESSION.md` (if exists)
- `/Users/craig.russell/games/damn_nature_you_scary/docs/TECHTREE_DESIGN.md`
- `/Users/craig.russell/games/damn_nature_you_scary/docs/TECHTREE.md`
- `/Users/craig.russell/games/damn_nature_you_scary/.specstory/history/2025-12-30_techtree.md`

**Current state:**
- [Working]
- [Broken/pending]

**Next step:** [Specific command + validation]
```

**Path rules:**
- **If in a worktree:** Use the worktree path (e.g., `.../worktrees/feat-xyz/CLAUDE.md`)
- **If in main repo:** Use the repo root path
- **Always include the Handover Key** so the next agent can verify continuity

---

## Domain Notes (Techtree Example)
If the session touched the damned_nature tech tree:
- Reference `TECHTREE.md`, `TECHTREE_DESIGN.md`, and the latest `.specstory` filenames in Spec Digest + Startup Prompt.
- Log validator results for `python3 tools/validate_techtree.py` and `python3 tools/validate_schemas.py`.
- Note clade/era invariants that were verified or broken.

---

## Writing Workflow
1. Gather data (commands above + validator output).
2. Read/refresh CLAUDE.md & design docs.
3. Update CLAUDE.md (or CLAUDE_SESSION.md for game-specific notes) using the template.
4. Double-check Spelling + AGENT-GENERATED header.
5. Produce the Startup Prompt inside the file and in your final response summary if helpful.

Keep bullets concise, cite absolute paths, and make sure the next agent knows exactly which command to run first.
