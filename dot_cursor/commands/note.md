# Note

You help users persist notes for this repo. Notes are stored in `CLAUDE/notes/` so future agents can access them.

## Think Before Acting

When a user says "note X":
1. **Parse the intent** - Is this context, a decision, a todo, or general info?
2. **Generate a slug** - Short, kebab-case description (e.g., "hydra-config", "additive-changes")
3. **Check for duplicates** - Does a similar note already exist?

---

## First: Check Existing Notes

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Show existing notes
if [ -d "$REPO_ROOT/CLAUDE/notes" ]; then
  echo "=== Existing Notes ==="
  ls -1 "$REPO_ROOT/CLAUDE/notes/"*.md 2>/dev/null | while read f; do
    echo "- $(basename "$f")"
    head -5 "$f" | grep -v "AGENT-GENERATED" | head -2
    echo ""
  done
else
  echo "No notes yet. This will be the first."
fi
```

---

## Create a Note

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Create notes directory
mkdir -p "$REPO_ROOT/CLAUDE/notes"

# Generate filename: NOTE-{YYYYMMDD}-{HHMM}-{slug}.md
NOTE_DATE=$(date +%Y%m%d-%H%M)
NOTE_SLUG="<your-slug-here>"  # e.g., "hydra-config"
NOTE_FILE="$REPO_ROOT/CLAUDE/notes/NOTE-${NOTE_DATE}-${NOTE_SLUG}.md"

echo "Creating: $NOTE_FILE"
```

---

## Note Template

Write the note using this format:

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# Note: <Title>

**Created:** <YYYY-MM-DD HH:MM>
**Category:** context | decision | todo | general

---

<Note content here>
```

---

## Categories

| Category | Use For |
|----------|---------|
| `context` | Repo patterns, conventions, how things work ("uses hydra for configs") |
| `decision` | Architectural choices, invariants ("always prefer additive changes") |
| `todo` | Persistent reminders that span sessions |
| `general` | Anything else worth remembering |

---

## Examples

**User says:** "note this repo uses hydra for config management"

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# Note: Hydra Config Management

**Created:** 2026-01-06 14:20
**Category:** context

---

This repo uses Hydra for configuration management.

- Config files are in `configs/`
- Use `@hydra.main` decorator for entry points
- Override with `+experiment=name` syntax
```

**User says:** "note @decision: always prefer additive changes over modifications"

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# Note: Additive Changes Policy

**Created:** 2026-01-06 14:25
**Category:** decision

---

**Invariant:** Always prefer additive changes over modifications in feature branches.

- Add new code rather than changing existing code
- Reduces merge conflicts
- Makes rollback easier
- Use abstractions to minimize net LOC changes
```

---

## List Notes for Agents

Other agents should check for notes at session start:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

if [ -d "$REPO_ROOT/CLAUDE/notes" ]; then
  echo "=== Repo Notes ==="
  for f in "$REPO_ROOT/CLAUDE/notes/"*.md; do
    [ -f "$f" ] || continue
    echo ""
    echo "### $(basename "$f")"
    cat "$f"
  done
fi
```

---

## Delete a Note

If a note is outdated, move it to backup (don't rm):

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
mkdir -p "$REPO_ROOT/CLAUDE/.backup"
mv "$REPO_ROOT/CLAUDE/notes/<note-file>.md" "$REPO_ROOT/CLAUDE/.backup/"
```

---

## Always End With Confirmation

After creating a note, confirm:

> "Created note: `CLAUDE/notes/NOTE-20260106-1420-hydra-config.md`"
> 
> "This repo now remembers: [brief summary]"

---

## Related Commands

| Need | Command |
|------|---------|
| Session handover | → **handover** |
| Check overall status | → **update** |
| Worktree awareness | → **worktrees** |




