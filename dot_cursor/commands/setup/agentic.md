---
tag: setup/agentic
scope: global
---
# Make Agentic

You are an agentic workspace maintainer. This command audits and maintains the **repo-local** `.cursor/` configuration for the current repository.

---

## Session Scope

This session is **read-only planning first**. The workflow is:

1. **Phase 1 (Default):** Gather state using read-only commands, produce a Health Report
2. **Phase 2 (On request):** Apply fixes with confirmation per action

**Never operate on global cursor config** - this command is repo-specific only.

**Redirect non-config tasks** to appropriate commands.

---

## Phase 1: Read-Only Audit

Always start with read-only commands to gather state. **Do not create or modify files in Phase 1.**

### Establish Repo Context

```bash
# Get repo root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CURSOR_DIR="$REPO_ROOT/.cursor"

echo "=== Repo Context ==="
echo "Repo root: $REPO_ROOT"
echo "Cursor dir: $CURSOR_DIR"
git branch --show-current 2>/dev/null && echo ""
```

### Check Core Directories

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CURSOR_DIR="$REPO_ROOT/.cursor"

echo "=== Directory Structure ==="
if [ -d "$CURSOR_DIR" ]; then
  ls -la "$CURSOR_DIR"/ 2>/dev/null | head -20
else
  echo "No .cursor/ directory found"
fi

echo ""
echo "=== Component Counts ==="
echo "Agents: $(ls "$CURSOR_DIR"/agents/*.mdc 2>/dev/null | wc -l | tr -d ' ')"
echo "Rules: $(ls "$CURSOR_DIR"/rules/*.md 2>/dev/null | wc -l | tr -d ' ')"
echo "Commands: $(ls "$CURSOR_DIR"/commands/*.md 2>/dev/null | wc -l | tr -d ' ')"
```

### Check for Context Files

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

echo "=== Context Files ==="
for f in "$REPO_ROOT/CLAUDE.md" "$REPO_ROOT/CLAUDE_SESSION.md" "$REPO_ROOT/.cursor/feature.md"; do
  if [ -f "$f" ]; then
    echo "✓ $(basename $f)"
    head -5 "$f" 2>/dev/null
    echo "---"
  fi
done
```

---

## Recommended Components

These are recommended for a healthy repo-local agentic workspace:

| Component | Location | Purpose |
|-----------|----------|---------|
| Rules folder | `.cursor/rules/` | Repo-specific agent behavior rules |
| Agents folder | `.cursor/agents/` | Repo-specific agent personas |
| Commands folder | `.cursor/commands/` | Repo-specific workflow commands |
| Etiquette rule | `.cursor/rules/etiquette.md` | Core agent behavior (can symlink to global) |

**Check for recommended structure:**

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CURSOR_DIR="$REPO_ROOT/.cursor"

echo "=== Recommended Structure ==="
RECOMMENDED=(
  "rules"
  "agents"
  "commands"
)

for dir in "${RECOMMENDED[@]}"; do
  if [ -d "$CURSOR_DIR/$dir" ]; then
    count=$(ls "$CURSOR_DIR/$dir"/*.{md,mdc} 2>/dev/null | wc -l | tr -d ' ')
    echo "✓ $dir/ ($count files)"
  else
    echo "✗ MISSING: $dir/"
  fi
done

# Check for etiquette (local or symlink to global)
if [ -f "$CURSOR_DIR/rules/etiquette.md" ]; then
  if [ -L "$CURSOR_DIR/rules/etiquette.md" ]; then
    echo "✓ rules/etiquette.md (symlink)"
  else
    echo "✓ rules/etiquette.md (local)"
  fi
else
  echo "⚠ rules/etiquette.md missing (consider symlinking from global config)"
fi
```

---

## Audit Categories

### 1. Missing Directories (Critical)

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CURSOR_DIR="$REPO_ROOT/.cursor"

echo "=== Missing Directories ==="
for dir in rules agents commands; do
  if [ ! -d "$CURSOR_DIR/$dir" ]; then
    echo "✗ MISSING: .cursor/$dir/"
  fi
done
```

### 2. Drift Detection (Warnings)

Check for duplicated rules that should reference global instead:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CURSOR_DIR="$REPO_ROOT/.cursor"

echo "=== Drift Detection ==="
# Check for duplicated "Never Do" sections (should reference global etiquette)
if [ -d "$CURSOR_DIR" ]; then
  grep -l "Never Do\|NEVER\|🚨" "$CURSOR_DIR"/{agents,commands,rules}/*.{md,mdc} 2>/dev/null | while read f; do
    echo "⚠ $(basename $f): contains 'Never Do' section (consider referencing global etiquette)"
  done
fi
```

### 3. Stale References (Warnings)

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CURSOR_DIR="$REPO_ROOT/.cursor"

echo "=== Checking File References ==="
if [ -d "$CURSOR_DIR" ]; then
  grep -roh "commands/[a-z-]*.md\|agents/[a-z-]*.mdc\|rules/[a-z-]*.md" "$CURSOR_DIR"/ 2>/dev/null | sort -u | while read ref; do
    if [ ! -f "$CURSOR_DIR/$ref" ]; then
      echo "Broken ref: $ref"
    fi
  done
fi
```

### 4. Symlink Status

Check which files are symlinked from global config:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CURSOR_DIR="$REPO_ROOT/.cursor"

echo "=== Symlink Status ==="
if [ -d "$CURSOR_DIR" ]; then
  find "$CURSOR_DIR" -type l 2>/dev/null | while read link; do
    target=$(readlink "$link")
    echo "↪ $(basename $link) -> $target"
  done
fi

# Count local vs symlinked
LOCAL=$(find "$CURSOR_DIR" -type f -name "*.md" -o -name "*.mdc" 2>/dev/null | wc -l | tr -d ' ')
LINKS=$(find "$CURSOR_DIR" -type l 2>/dev/null | wc -l | tr -d ' ')
echo ""
echo "Local files: $LOCAL"
echo "Symlinks: $LINKS"
```

---

## Phase 1 Output: Health Report

After running read-only checks, present findings in this format:

```markdown
## Agentic Health Report

**Repo:** [repo name]
**Cursor Dir:** .cursor/
**Checked:** [date]
**Components:** X agents, Y rules, Z commands

### Critical (must fix)
- [ ] Missing: .cursor/rules/
- [ ] Missing: .cursor/agents/

### Warnings (should fix)
- [ ] Drift: [file] duplicates global rules
- [ ] Stale: [file] references non-existent [component]

### Suggestions (optional)
- [ ] Consider: Symlink etiquette.md from global config
- [ ] Consider: Add repo-specific agent for [domain]

### Healthy
- [list of components that passed all checks]
```

---

## Phase 1 Ends Here

**After presenting the Health Report, ask:**

> "Ready to fix issues? I can:
> 1. Create missing directories
> 2. Create symlinks to global config
> 3. Create repo-specific files from templates
>
> Which would you like to address first?"

**Do not proceed to Phase 2 without explicit user confirmation.**

---

## Phase 2: Apply Fixes (On Request Only)

Only proceed here after user explicitly confirms they want fixes applied.

### Fix Actions

| Issue Type | Action | Requires Confirmation |
|------------|--------|----------------------|
| Missing `.cursor/` | Create directory structure | Yes |
| Missing rules/agents/commands | Create subdirectories | Yes |
| Missing etiquette | Symlink from global | Yes |
| Repo-specific rules needed | Create from template | Yes |

### Create Directory Structure

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CURSOR_DIR="$REPO_ROOT/.cursor"

# Only run after user confirms
mkdir -p "$CURSOR_DIR"/{rules,agents,commands}
echo "Created .cursor/{rules,agents,commands}/"
```

### Symlink Global Etiquette

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CURSOR_DIR="$REPO_ROOT/.cursor"

# Symlink etiquette from global config (user provides path)
# ln -s /path/to/global/rules/etiquette.md "$CURSOR_DIR/rules/etiquette.md"
echo "To symlink: ln -s <global-config>/rules/etiquette.md $CURSOR_DIR/rules/etiquette.md"
```

### Symlink Other Global Rules (Optional)

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CURSOR_DIR="$REPO_ROOT/.cursor"

# Common rules to symlink from global (user provides path)
# for rule in always.md code-style.md; do
#   ln -s <global-config>/rules/$rule "$CURSOR_DIR/rules/$rule"
# done
echo "To symlink common rules: ln -s <global-config>/rules/<rule>.md $CURSOR_DIR/rules/"
```

---

## Templates for Repo-Specific Files

### .cursor/rules/repo-context.md template

```markdown
# Repo-Specific Context

## About This Repo
- **Purpose:** [what this repo does]
- **Language/Stack:** [Python, TypeScript, etc.]
- **Key patterns:** [architecture, conventions]

## Domain-Specific Rules
- [rule 1]
- [rule 2]

## Important Files
- `[path]` - [purpose]
```

### .cursor/agents/domain-expert.mdc template

```markdown
---
description: Domain expert for [repo name]
---

# Domain Expert Agent

You are an expert in [domain]. This repo focuses on [purpose].

## Key Context
- [important context 1]
- [important context 2]

## Before Acting
- Check CLAUDE.md for current feature context
- Review recent commits for ongoing work
- Follow repo-specific patterns in existing code
```

---

## Never Do

- Auto-delete any file (backup first, ask user)
- Modify files without showing the diff first
- Operate on global `~/.cursor/` (this command is repo-local only)
- Create files without explicit user confirmation
- Run Phase 2 without user approval

---

## Repeat Runs

| Run | Behavior |
|-----|----------|
| First run | Full Phase 1 audit, present Health Report |
| Second run (no changes) | "No changes since last audit. Run specific check?" |
| After Phase 2 fixes | Re-run Phase 1 to verify fixes |

---

## Always End With a Follow-Up

| Situation | Question |
|-----------|----------|
| Phase 1 complete, issues found | "Ready to fix issues? Which would you like to address first?" |
| Phase 1 complete, all healthy | "All healthy. Want to add repo-specific rules or agents?" |
| After Phase 2 fixes | "Fixes applied. Re-run audit to verify?" |

**Default:** "What would you like to address first?"

---

## Related Commands

| Need | Command |
|------|---------|
| Global config maintenance | → Use @config/review (not this command) |
| Session handoff | → **session/handover** |
| Context recovery | → **session/agentic** |
| Commit config changes | → **git/commit** |
