# Todo

Manage todos for this repo. Todos are stored in `CLAUDE/todos/` and surfaced with agent-suggested priorities.

---

## Mode Detection

- **No args** (`/todo`): View and prioritize all todos
- **With args** (`/todo fix the API bug`): Add a new todo

---

## View Mode: Scan & Prioritize

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

echo "=== Scanning for Todos ==="

# 1. CLAUDE.md checkboxes and pending items
if [ -f "$REPO_ROOT/CLAUDE.md" ]; then
  echo "--- CLAUDE.md ---"
  grep -E "^\s*-\s*\[ \]|TODO|Pending|⏳" "$REPO_ROOT/CLAUDE.md" 2>/dev/null || echo "(none)"
fi

# 2. Notes with category: todo
if [ -d "$REPO_ROOT/CLAUDE/notes" ]; then
  echo "--- Notes (category: todo) ---"
  grep -l "category.*todo" "$REPO_ROOT/CLAUDE/notes/"*.md 2>/dev/null | head -5
fi

# 3. Dedicated todos
if [ -d "$REPO_ROOT/CLAUDE/todos" ]; then
  echo "--- CLAUDE/todos/ ---"
  ls -1t "$REPO_ROOT/CLAUDE/todos/"*.md 2>/dev/null | while read f; do
    status=$(grep -m1 "Status:" "$f" | sed 's/.*Status:\s*//')
    echo "- $(basename "$f") [$status]"
  done
fi
```

After scanning, analyze and output a prioritized list:

```markdown
## Prioritized Todos

| Pri | Todo | Source | Status |
|-----|------|--------|--------|
| P1 | ... | CLAUDE.md | open |
| P2 | ... | todos/... | in-progress |
```

### Prioritization Heuristics

- **P1 (Critical):** Blocking issues, bugs, dependencies for current work
- **P2 (Important):** Features in current plan, older open items
- **P3 (Nice-to-have):** Cleanup, future ideas, low urgency

Consider: current CLAUDE.md plan context, age of todo, blocking relationships.

---

## Add Mode: Create Todo

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
mkdir -p "$REPO_ROOT/CLAUDE/todos"

TODO_DATE=$(date +%Y%m%d-%H%M)
TODO_SLUG="<slug-from-request>"  # kebab-case
TODO_FILE="$REPO_ROOT/CLAUDE/todos/TODO-${TODO_DATE}-${TODO_SLUG}.md"
```

### Todo Template

```markdown
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# Todo: <Title>

**Created:** <YYYY-MM-DD HH:MM>
**Status:** open
**Priority:** (suggested on view)

---

<Description from user request>
```

### Status Values

| Status | Meaning |
|--------|---------|
| `open` | Not started |
| `in-progress` | Currently working |
| `done` | Completed |
| `blocked` | Waiting on something |

---

## Confirm Actions

**After viewing:**
> "Found X todos across Y sources. Prioritized list above. What needs attention first?"

**After adding:**
> "Created todo: `CLAUDE/todos/TODO-20260107-1420-fix-api-bug.md`"

---

## Related Commands

| Need | Command |
|------|---------|
| Persist general notes | → **note** |
| Session handover | → **handover** |
| Check overall status | → **update** |

