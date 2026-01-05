# Make Agentic

You are an agentic workspace maintainer. This command audits and maintains the global `~/.cursor/` configuration that powers all agent sessions.

---

## Session Scope

This session is **config maintenance only**. Handle:
- Auditing agentic components (agents, rules, commands)
- Detecting missing, stale, or drifted configurations
- Suggesting improvements based on usage patterns
- Creating missing standard files (with confirmation)

**Redirect non-config tasks** to appropriate commands.

---

## First: Health Check

Always start by gathering the current state:

```bash
# Check core directories exist
ls -la ~/.cursor/{agents,rules,commands}/ 2>/dev/null | head -40

# Check for context file
head -5 ~/.cursor/CLAUDE.md 2>/dev/null

# Count components
echo "=== Component Counts ==="
echo "Agents: $(ls ~/.cursor/agents/*.mdc 2>/dev/null | wc -l)"
echo "Rules: $(ls ~/.cursor/rules/*.md 2>/dev/null | wc -l)"
echo "Commands: $(ls ~/.cursor/commands/*.md 2>/dev/null | wc -l)"
```

---

## Required Components

These must exist for a healthy agentic workspace:

| Component | Location | Purpose |
|-----------|----------|---------|
| Etiquette | `rules/etiquette.md` | Source of truth for all agent behavior |
| Safety rules | `rules/safety.md` | Never-do list with verification checklists |
| Always rules | `rules/always.md` | Think-before-acting protocols |
| Code style | `rules/code-style.md` | Formatting standards (black/ruff) |
| Research agent | `agents/research.mdc` | ML research persona (fail-fast) |
| Engineering agent | `agents/engineering.mdc` | Production code persona |
| Handover cmd | `commands/handover.md` | Session handoff protocol |
| Continue cmd | `commands/continue-agentic.md` | Context recovery workflow |

**Check for required files:**
```bash
cd ~/.cursor
REQUIRED=(
  "rules/etiquette.md"
  "rules/safety.md"
  "rules/always.md"
  "rules/code-style.md"
  "agents/research.mdc"
  "agents/engineering.mdc"
  "commands/handover.md"
  "commands/continue-agentic.md"
)

echo "=== Required Components ==="
for f in "${REQUIRED[@]}"; do
  if [ -f "$f" ]; then
    echo "✓ $f"
  else
    echo "✗ MISSING: $f"
  fi
done
```

---

## Audit Categories

### 1. Missing Files (Critical)

Check if required components exist:
```bash
# Files that MUST exist
ls ~/.cursor/rules/{etiquette,safety,always,code-style}.md 2>&1 | grep -v "^/"
```

### 2. Drift Detection (Warnings)

Check for consistency across files:

**Etiquette is now a rule (auto-applied), so commands don't need preambles.**

**Check for duplicated rules (should reference, not copy):**
```bash
# Look for "Never" lists that might be duplicated instead of referenced
echo "=== Files with 'NEVER' sections (check for duplication) ==="
grep -l "Never Do\|NEVER\|🚨" ~/.cursor/{agents,commands,rules}/*.{md,mdc} 2>/dev/null
```

### 3. Stale Entries (Warnings)

**Check for broken file references:**
```bash
echo "=== Checking file references ==="
# Find references to .md and .mdc files and verify they exist
grep -roh "commands/[a-z-]*.md\|agents/[a-z-]*.mdc\|rules/[a-z-]*.md" ~/.cursor/{commands,agents,rules}/ 2>/dev/null | sort -u | while read ref; do
  if [ ! -f ~/.cursor/"$ref" ]; then
    echo "Broken ref: $ref"
  fi
done
```

**Check for outdated CLAUDE.md:**
```bash
# If CLAUDE.md exists, check if it's stale (>7 days old)
if [ -f ~/.cursor/CLAUDE.md ]; then
  MODIFIED=$(stat -f %m ~/.cursor/CLAUDE.md 2>/dev/null || stat -c %Y ~/.cursor/CLAUDE.md 2>/dev/null)
  NOW=$(date +%s)
  DAYS_OLD=$(( (NOW - MODIFIED) / 86400 ))
  if [ "$DAYS_OLD" -gt 7 ]; then
    echo "⚠ CLAUDE.md is $DAYS_OLD days old - may be stale"
  else
    echo "✓ CLAUDE.md updated $DAYS_OLD days ago"
  fi
fi
```

### 4. Improvement Suggestions (Optional)

**Commands without proper structure:**
```bash
echo "=== Structure Check ==="
for f in ~/.cursor/commands/*.md; do
  # Check for required sections
  name=$(basename "$f")
  has_scope=$(grep -c "Session Scope\|## Scope" "$f")
  has_workflow=$(grep -c "Workflow\|## First\|## Steps" "$f")
  has_related=$(grep -c "Related Commands\|## Related" "$f")
  
  if [ "$has_scope" -eq 0 ] || [ "$has_workflow" -eq 0 ]; then
    echo "⚠ $name: missing Session Scope or Workflow section"
  fi
done
```

**Agents without CLAUDE.md guidance:**
```bash
echo "=== Agent CLAUDE.md awareness ==="
for f in ~/.cursor/agents/*.mdc; do
  if ! grep -q "CLAUDE.md" "$f"; then
    echo "⚠ $(basename $f): no CLAUDE.md guidance"
  fi
done
```

### 5. Shell Environment Diagnostics

Cursor's terminal may not see installed tools because non-interactive shells skip `.zshrc`/`.bashrc`. This section diagnoses shell configuration issues.

| Check | What it detects |
|-------|-----------------|
| Shell type | `$SHELL` vs actual shell (zsh/bash/fish) |
| Interactive mode | Whether rc files are being sourced |
| PATH comparison | Differences between interactive and non-interactive shells |
| RC file presence | `.zshenv`, `.zshrc`, `.bashrc`, `.bash_profile`, `.profile` |
| Env managers | pyenv, nvm, conda, rbenv initialization status |

**Shell type and RC files:**
```bash
echo "=== Shell Environment ==="
echo "Login shell: $SHELL"
echo "Current shell: $0"
echo "Process: $(ps -p $$ -o comm=)"

echo ""
echo "=== RC Files Present ==="
for rc in ~/.zshenv ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile; do
  if [ -f "$rc" ]; then
    echo "✓ $rc ($(wc -l < "$rc") lines)"
  else
    echo "✗ $rc"
  fi
done
```

**PATH in current shell:**
```bash
echo "=== Current PATH (first 10 entries) ==="
echo $PATH | tr ':' '\n' | head -10

# Check for common missing directories
echo ""
echo "=== Common PATH Checks ==="
for dir in /usr/local/bin /opt/homebrew/bin ~/.local/bin; do
  if echo $PATH | grep -q "$dir"; then
    echo "✓ $dir in PATH"
  else
    echo "⚠ $dir NOT in PATH"
  fi
done
```

**Environment managers:**
```bash
echo "=== Environment Managers ==="
# pyenv
if command -v pyenv &>/dev/null; then
  echo "✓ pyenv: $(pyenv root 2>/dev/null || echo 'installed')"
  echo "  Python: $(pyenv version-name 2>/dev/null)"
else
  echo "✗ pyenv: not found"
fi

# nvm
if [ -n "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
  echo "✓ nvm: $NVM_DIR"
  echo "  Node: $(node --version 2>/dev/null || echo 'not activated')"
elif [ -d "$HOME/.nvm" ]; then
  echo "⚠ nvm: installed but not initialized"
else
  echo "✗ nvm: not found"
fi

# conda
if command -v conda &>/dev/null; then
  echo "✓ conda: $(conda info --base 2>/dev/null)"
else
  echo "✗ conda: not found"
fi

# rbenv
if command -v rbenv &>/dev/null; then
  echo "✓ rbenv: $(rbenv root 2>/dev/null)"
else
  echo "✗ rbenv: not found"
fi
```

**Non-interactive vs interactive PATH comparison (key diagnostic):**
```bash
echo "=== PATH Comparison (Interactive vs Non-Interactive) ==="
# Get PATH from non-interactive shells
ZSH_PATH=$(zsh -c 'echo $PATH' 2>/dev/null)
BASH_PATH=$(bash -c 'echo $PATH' 2>/dev/null)
CURRENT_PATH=$PATH

# Count entries
ZSH_COUNT=$(echo "$ZSH_PATH" | tr ':' '\n' | wc -l | tr -d ' ')
BASH_COUNT=$(echo "$BASH_PATH" | tr ':' '\n' | wc -l | tr -d ' ')
CURRENT_COUNT=$(echo "$CURRENT_PATH" | tr ':' '\n' | wc -l | tr -d ' ')

echo "Current shell PATH entries: $CURRENT_COUNT"
echo "Non-interactive zsh PATH entries: $ZSH_COUNT"
echo "Non-interactive bash PATH entries: $BASH_COUNT"

if [ "$CURRENT_COUNT" -ne "$ZSH_COUNT" ]; then
  echo "⚠ PATH differs between interactive and non-interactive zsh"
  echo "  This can cause tools to be missing in Cursor terminals"
fi
```

---

## Output Format

Present findings as a structured report:

```markdown
## Agentic Health Report

**Workspace:** ~/.cursor/
**Checked:** [date]
**Components:** X agents, Y rules, Z commands

### Critical (fix now)
- [ ] Missing: [file path]

### Warnings (should fix)
- [ ] Stale: [file] references deleted [component]
- [ ] Duplicate: [file] copies rules instead of referencing

### Suggestions (optional)
- [ ] Consider: Add CLAUDE.md guidance to [agent]
- [ ] Consider: Add Related Commands section to [command]

### Shell Environment
- Shell: [zsh/bash] | Interactive: [yes/no]
- RC files: [.zshenv, .zshrc, etc. - which are present]
- Env managers: [pyenv/nvm/conda - status of each]
- PATH issues: [any missing dirs or interactive/non-interactive differences]

### Healthy ✓
- [list of components that passed all checks]
```

---

## Fix Actions

After reporting, offer to fix issues (with confirmation):

| Issue Type | Action | Requires Confirmation |
|------------|--------|----------------------|
| Missing required file | Create from template | Yes |
| Missing CLAUDE.md guidance | Add CLAUDE.md section to agent | Yes |
| Stale references | Flag for manual review | No (just report) |
| Missing `.zshenv` | Create with PATH exports | Yes |
| Env manager not in `.zshenv` | Add init commands to `.zshenv` | Yes |
| PATH differs interactive/non-interactive | Suggest moving PATH setup to `.zshenv` | Yes |

**Never auto-delete files** - follow safety rules. Move to backup if removal needed.

---

## Templates for Missing Files

If core files are missing, offer to create them:

### rules/always.md template
```markdown
# Always Rules

These rules apply to EVERY interaction, regardless of context.

## Before ANY Action

**STOP and verify:**
1. Am I about to push code? → Don't. User pushes manually.
2. Am I about to commit? → Only if explicitly asked.
3. Am I about to delete/rm? → Backup first, or use mv.

## Think Before Acting

For any non-trivial task, briefly state:
1. What I understand the request to be
2. What I'm about to do
3. Any risks or concerns
```

### rules/safety.md template
```markdown
# Safety Rules

## 🚨 NEVER Do These

| Action | Why | Instead |
|--------|-----|---------|
| `git push` | User controls remote | Ask permission, wait |
| `git commit` without ask | User decides timing | Only when explicitly asked |
| `rm` anything | Data loss risk | `mv` to backup location |
| try/catch blocks | Hides errors | Let errors propagate |
```

### ~/.zshenv template (for shell environment issues)

**Why `.zshenv`?** Cursor uses non-interactive shells, which skip `.zshrc`. Only `.zshenv` is sourced for all zsh invocations, making it the right place for PATH and environment manager setup.

```bash
# ~/.zshenv - Sourced for ALL zsh shells (interactive and non-interactive)
# This ensures tools are available in Cursor terminals

# Homebrew (Apple Silicon)
if [ -d "/opt/homebrew/bin" ]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

# Homebrew (Intel)
if [ -d "/usr/local/bin" ]; then
  export PATH="/usr/local/bin:$PATH"
fi

# Local binaries
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# pyenv
if [ -d "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
fi

# nvm (Node Version Manager)
if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
fi

# rbenv
if [ -d "$HOME/.rbenv" ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init - --no-rehash)"
fi

# Cargo (Rust)
if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi
```

**After creating `.zshenv`:** Restart Cursor completely (not just the terminal) for changes to take effect.

---

## Repeat Runs

When run again:

1. **First run today:** Full audit with all categories
2. **Second run same session:** Show delta from last check
3. **Run after changes:** Verify fixes were applied correctly

If nothing changed since last run:
> "All components healthy. Last checked [time]. Run specific audit? (missing/drift/stale/suggest)"

---

## Never Do

- Auto-delete any file (backup first, ask user)
- Modify files without showing the diff first
- Push any changes to remote

---

## Always End With a Follow-Up

| Situation | Question |
|-----------|----------|
| Issues found | "Want me to fix the critical issues first?" |
| All healthy | "Anything specific you want to add or improve?" |
| After fixes | "Should I re-run the audit to verify?" |

**Default:** "What would you like to address first?"

---

## Related Commands

| Need | Command |
|------|---------|
| Commit config changes | → **git-manager** |
| Session handoff | → **handover** |
| Context recovery | → **continue-agentic** |
| Sync to remote servers | → **sync-remote** |

