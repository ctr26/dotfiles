# Handover Assistant

Summarize session into a handover document so the next agent can rebuild from scratch.

See `~/.cursor/rules/context-gathering.md` for environment setup.

---

## Resume from Key

If invoked with a key (e.g., `/handover HO-20260106-1423-a1b2`):

1. Find the handover file: `CLAUDE/[provided-key].md`
2. Read and summarize the previous session state
3. Show what was pending and the startup prompt
4. Ask: "Ready to continue from this handover, or create a new one?"

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
HO_KEY="[provided-key]"
cat "$REPO_ROOT/CLAUDE/${HO_KEY}.md" 2>/dev/null || echo "Handover file not found"
```

---

## What to Capture

- **Spec Digest** (sources + invariants)
- **What changed** (files, decisions)
- **Validation status** (tests run)
- **Next steps / blockers**
- **Startup prompt** (copy-paste ready)

---

## Generate Handover Key

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
BRANCH=$(git branch --show-current 2>/dev/null || echo "none")
HO_KEY="HO-$(date +%Y%m%d-%H%M)-$(echo "${BRANCH}$(date +%s)" | md5sum | cut -c1-4)"
mkdir -p CLAUDE
echo "Key: $HO_KEY | File: CLAUDE/${HO_KEY}.md"
```

Store key in: handover file, CLAUDE.md index, and your response.

---

## Worktree Detection

```bash
# Detect worktree and set MAIN_REPO if applicable
GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "$GIT_COMMON_DIR" ] && [ -n "$GIT_COMMON_DIR" ]; then
    MAIN_REPO=$(dirname "$GIT_COMMON_DIR")
    mkdir -p "$MAIN_REPO/CLAUDE"
    echo "Will also write to: $MAIN_REPO/CLAUDE/${HO_KEY}.md"
fi
```

---

## Gather Context

```bash
git status --short
git log --oneline --since="12 hours ago" | head -10
ls CLAUDE.md CLAUDE_SESSION.md CLAUDE/ 2>/dev/null
ls -lt .specstory/history/*.md 2>/dev/null | head -5
```

---

## Handover Template

Create at `CLAUDE/$HO_KEY.md`:

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# Session Handover

**Key:** [HO_KEY] | **Date:** [date] | **Agent:** [agent-name]
**Branch:** [branch] | **Focus:** [one-line summary]

---

## Spec Digest
- **Sources:** [list]
- **Invariants:** [non-negotiables]
- **Acceptance:** [tests]

## What Changed
- `file` – description

## Commits
[hash] [message] (or "None")

## Validation
| Command | Result |
|---------|--------|
| `make test` | PASS |

## Pending
- [ ] Task with acceptance criteria

## Key Decisions
| Decision | Reason |
|----------|--------|

## Next Session
- First action
- Blockers

## Startup Prompt
**Handover Key:** [HO_KEY]
**Agent:** [agent-name]
**Branch:** `[branch]`
**Read:** `CLAUDE/[HO_KEY].md`
**First action:** [what to do]
```

---

## Worktree: Dual Write

When in a worktree, write the same handover file to both locations:

1. `$REPO_ROOT/CLAUDE/$HO_KEY.md` (worktree - primary)
2. `$MAIN_REPO/CLAUDE/$HO_KEY.md` (main repo - visibility)

Update both `CLAUDE.md` indexes to point to the handover.

The main repo copy provides visibility into all worktree activity from one place.

---

## CLAUDE.md Index

Keep minimal – just points to current handover:

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# CLAUDE.md

**Current Handover:** `CLAUDE/[HO_KEY].md`
**Agent:** [agent-name]
**Branch:** [branch]
**Focus:** [summary]
```

---

## Workflow

1. Derive agent name (see `~/.cursor/rules/context-gathering.md`)
2. Generate handover key
3. Gather context + validator output
4. Create `CLAUDE/$HO_KEY.md` (worktree)
5. **If in worktree:** Also create `$MAIN_REPO/CLAUDE/$HO_KEY.md`
6. Update `CLAUDE.md` index (worktree)
7. **If in worktree:** Also update `$MAIN_REPO/CLAUDE.md` index
8. Print key + agent name at end of response

---

## Planning Mode: New Agent

When in planning mode (plan exists but not executed), guide the user to spawn a fresh agent:

### Instructions to Provide

After creating the handover file, tell the user:

> **To continue with a fresh agent:**
> 1. Open a new Cursor tab (Cmd+T or Ctrl+T)
> 2. Copy-paste this startup prompt:
>
> ```
> /handover [HO_KEY]
> 
> Continue from handover. The plan is ready to execute.
> ```

### When to Use

| Scenario | Action |
|----------|--------|
| Plan created, not executed | Suggest new agent with startup prompt |
| Long chat (15+ messages) with pending plan | Suggest handover + new agent |
| Context confusion during planning | Immediate handover + new agent |

---

## Always End With Key

```
---
**Handover Key:** HO-20260106-1423-a1b2
**Agent:** feat/data-loader
**Handover File:** CLAUDE/HO-20260106-1423-a1b2.md
```
