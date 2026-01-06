# Handover Assistant

You summarize the current session into a handover document in `CLAUDE/` so the next agent can rebuild the feature from scratch. A good handover captures:
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
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

# Generate handover key: HO-{YYYYMMDD}-{HHMM}-{4char-hash}
BRANCH=$(git branch --show-current 2>/dev/null || echo "none")
HO_KEY="HO-$(date +%Y%m%d-%H%M)-$(echo "${BRANCH}$(date +%s)" | md5sum | cut -c1-4)"

# Create CLAUDE directory and set handover file path
mkdir -p CLAUDE
HANDOVER_FILE="CLAUDE/${HO_KEY}.md"

echo "Handover Key: $HO_KEY"
echo "Handover File: $HANDOVER_FILE"
```

Store this key in:
1. **`$HANDOVER_FILE`** (the detailed handover document)
2. **`CLAUDE.md`** (lightweight index pointing to handover file)
3. **Your response** (always print at end for user to copy)

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
    echo "Handover location: $REPO_ROOT/CLAUDE/ (worktree-local)"
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

## Handover File Template (Required Sections)

**Location:** Create handover file at `CLAUDE/$HO_KEY.md` in the repo root. When in a worktree, this is the worktree root - NOT the main repo.

All handover files must contain:

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# Session Handover

**Handover Key:** [HO_KEY from generation step]
**Last updated:** 2025-12-30 14:05
**Branch:** feature/xyz
**Worktree:** [worktree path if applicable, else "main repo"]
**Session focus:** [one-line summary]

---

## Spec Digest
- **Sources:** CLAUDE_SESSION.md, docs/TECHTREE_DESIGN.md, 2025-12-30_techtree.md
- **Invariants:** [bullet list of non-negotiables]
- **Acceptance:** [tests/validators that constitute "done"]

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

## What's Pending
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
**Handover Key:** [HO_KEY]
[See startup prompt template below]
```
```

Every section above is mandatory. If something doesn't apply, explicitly write "None".

---

## CLAUDE.md Index Template

**Location:** `CLAUDE.md` at repo root serves as a lightweight index pointing to the current handover.

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# CLAUDE.md - Session Index

**Current Handover:** `CLAUDE/HO-XXXXXXXX-XXXX-XXXX.md`
**Branch:** feature/xyz
**Session focus:** [one-line summary]

## Recent Handovers
| Key | Date | Focus |
|-----|------|-------|
| HO-20260106-1423-a1b2 | 2026-01-06 | [summary] |

## Quick Links
- Current handover: `CLAUDE/HO-XXXXXXXX-XXXX-XXXX.md`
- Session notes: `CLAUDE_SESSION.md` (if exists)
- Design docs: [relevant paths]
```

Keep CLAUDE.md minimal - all detailed context lives in the handover file.

---

## Startup Prompt Template
```markdown
## Startup Prompt (copy this to new agent)

**Handover Key:** [HO_KEY from generation step]
**Continue working on:** [feature]

**Repo:** `/path/to/repo`
**Worktree:** `/path/to/worktree` (if applicable)
**Branch:** `feature/xyz`
**Handover file:** `[repo path]/CLAUDE/[HO_KEY].md`

**Read these first:**
- `[repo path]/CLAUDE/[HO_KEY].md` (current handover)
- `[repo path]/CLAUDE.md` (session index)
- `[repo path]/CLAUDE_SESSION.md` (if exists)
- [relevant design docs]
- [recent .specstory entries]

**Current state:**
- [Working]
- [Broken/pending]

**Next step:** [Specific command + validation]
```

**Path rules:**
- **If in a worktree:** Use the worktree path for CLAUDE/ directory
- **If in main repo:** Use the repo root path
- **Always include the Handover Key** so the next agent can verify continuity
- **Reference the specific handover file** (`CLAUDE/$HO_KEY.md`) not just CLAUDE.md

---

## Domain Notes (Techtree Example)
If the session touched the damned_nature tech tree:
- Reference `TECHTREE.md`, `TECHTREE_DESIGN.md`, and the latest `.specstory` filenames in Spec Digest + Startup Prompt.
- Log validator results for `python3 tools/validate_techtree.py` and `python3 tools/validate_schemas.py`.
- Note clade/era invariants that were verified or broken.

---

## Writing Workflow

1. **Generate handover key** using the command above.
2. **Gather data** (context commands + validator output).
3. **Create handover file** at `CLAUDE/$HO_KEY.md` using the template.
4. **Update CLAUDE.md index** to point to the new handover file.
5. **Double-check** spelling + AGENT-GENERATED headers on both files.
6. **Print handover key** at the end of your response (see below).

Keep bullets concise, cite absolute paths, and make sure the next agent knows exactly which command to run first.

---

## Always Print Handover Key

**Every handover response must end with the handover key prominently displayed:**

```
---
**Handover Key:** HO-20260106-1423-a1b2
**Handover File:** CLAUDE/HO-20260106-1423-a1b2.md
```

This makes it easy for the user to copy/paste when starting a new agent session. The key should be the last thing in your response.
