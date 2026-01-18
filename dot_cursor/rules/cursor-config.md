# Cursor Configuration Reference

How rules, commands, and agents are built in `~/.cursor/`.

---

## Directory Structure

```
~/.cursor/
├── rules/          # Always-active behavior (*.mdc for auto-load, *.md for reference)
├── commands/       # User-triggered workflows (*.md)
└── agents/         # Specialized personas (*.mdc)
```

| Folder | Extension | Activation | Purpose |
|--------|-----------|------------|---------|
| `rules/` | `.mdc` | Auto-loaded (with frontmatter) | Enforced constraints, style rules |
| `rules/` | `.md` | Reference only (not auto-loaded) | Documentation, extended examples |
| `commands/` | `.md` | User invokes (`/command`) | Task-specific workflows |
| `agents/` | `.mdc` | User selects | Specialized personas with model config |

---

## Rules (`rules/*.mdc`)

**Critical:** Only `.mdc` files with YAML frontmatter are auto-loaded by Cursor.

### Rule Types

| Type | Extension | Frontmatter | When Applied |
|------|-----------|-------------|--------------|
| Always-on | `.mdc` | `alwaysApply: true` | Every interaction |
| Conditional | `.mdc` | `globs: [...]` | When file pattern matches |
| Reference | `.md` | None | Never auto-loaded (documentation only) |

### Frontmatter Format

```yaml
---
name: 'Rule Name'
description: 'One-line purpose'
alwaysApply: true  # OR use globs for conditional
# globs: ["**/src/**/*"]  # Optional: only apply to matching files
---
```

### Naming Convention
- Lowercase with hyphens: `core.mdc`, `dir-src.mdc`
- Prefix with `dir-` for directory-conditional rules
- Names should be self-descriptive

### Current Rules

| File | alwaysApply | Purpose |
|------|-------------|---------|
| `core.mdc` | true | Safety, ask_question enforcement, style |
| `dir-src.mdc` | false (globs) | Production code patterns |
| `dir-experiments.mdc` | false (globs) | ML experiment patterns |
| `dir-notebooks.mdc` | false (globs) | Jupyter notebook patterns |
| `dir-scripts.mdc` | false (globs) | Utility script patterns |
| `dir-tests.mdc` | false (globs) | Test file patterns |

### Reference Files (Not Auto-Loaded)

| File | Purpose |
|------|---------|
| `always.md` | Extended safety documentation |
| `etiquette.md` | Comprehensive agent behavior guide |
| `workflow.md` | Git and handover patterns |
| `ask-question.md` | ask_question tool reference |

---

## Commands (`commands/*.md`)

Commands are user-triggered workflows. Invoke with `@command-name`.

### Naming Convention
- Lowercase with hyphens: `commit.md`, `sweep.md`
- Use hierarchical folders: `git/`, `ml/`, `session/`, `sync/`

### Required Sections

```markdown
# Command Name

You are a [role]. [One-line purpose].

## Session Scope
[What this command handles / redirects]

## Think Before Acting
[Plan before executing - what, how, risks]

## Workflow
[Step-by-step process]

## Never Do
[Command-specific restrictions]

## Always End With a Follow-Up Question
[Keep momentum with relevant questions]

## Related Commands
| Situation | Suggest |
|-----------|---------|
| Need X | → **other-command** |
```

### Current Commands

| Path | Purpose |
|------|---------|
| `git/commit` | Staging, committing, branching |
| `git/pr` | Split changes into PRs via worktrees |
| `git/cherry-pick` | Cherry-pick commits between branches |
| `git/worktree` | Create isolated worktrees |
| `session/handover` | Session handover with unique keys |
| `session/continue` | Resume previous work |
| `session/eod` | End of day summary |
| `ml/sweep` | WandB sweeps on Slurm |
| `sync/remote` | Sync config to remote servers |
| `config/review` | Review cursor config |
| `update` | Comprehensive status check |
| `ideate` | Brainstorming/planning mode |
| `note` | Persist notes to CLAUDE/ |
| `todo` | Manage todos |

---

## Agents (`agents/*.mdc`)

Agents are specialized personas with model configuration. Uses `.mdc` extension (markdown with frontmatter).

### Frontmatter Format

```yaml
---
name: 'Agent Name'
model: claude-opus-4-20250514
description: 'One-line purpose'
---
```

### Model Selection
| Task Type | Model | Reasoning |
|-----------|-------|-----------|
| Complex/safety-critical | `claude-opus-4-*` | Best reasoning |
| Standard coding | `claude-sonnet-4-*` | Good balance |
| Simple tasks | `claude-haiku-*` | Fast/cheap |

### Agent Structure

```markdown
---
name: 'Engineering'
model: claude-opus-4-20250514
description: 'Production engineering - robust code'
---

# Engineering Agent

You are a [role]. [Context].

## Core Principles
[What this agent prioritizes]

## Before Any Action
[Pre-flight checks specific to domain]

## [Domain-Specific Sections]
[Tables, checklists, examples]

## CLAUDE.md
[How this agent uses CLAUDE.md]

## Never Do
[Agent-specific restrictions]
```

### Current Agents
| File | Purpose | Model |
|------|---------|-------|
| `engineering.mdc` | Production code, system design | opus |
| `research.mdc` | Research/ML experimentation | opus |
| `sweep-ops.mdc` | Slurm/WandB sweep operations | opus |
| `git-ops.mdc` | Git operations specialist | opus |
| `reviewer.mdc` | Code review | opus |
| `games-builder.mdc` | Game development | opus |

---

## Common Patterns

### Tables for Quick Reference
```markdown
| Action | Command | Notes |
|--------|---------|-------|
| Commit | `git add && git commit` | Atomic |
```

### Good/Bad Examples
```markdown
### Bad Examples
```bash
# Don't do this
sleep 30 && echo "done"
```

### Good Examples
```bash
# Do this instead
timeout 10 some_command
```
```

### Verification Checklists
```markdown
### Before Committing
- [ ] User explicitly said "commit"
- [ ] Commit message follows [tag] format
- [ ] One concern per commit
```

### Follow-Up Question Tables
```markdown
| Situation | Example Questions |
|-----------|-------------------|
| After task | "Should I commit this?" |
| Unclear | "Could you clarify?" |

**Default:** "What would you like to do next?"
```

---

## Creating New Configurations

### New Rule (Auto-Loaded)
1. Create `rules/my-rule.mdc` (note: `.mdc` extension required)
2. Add YAML frontmatter with `name`, `description`, and either:
   - `alwaysApply: true` for always-on rules
   - `globs: ["pattern"]` for conditional rules
3. Add "Never Do" and "Always Do" sections
4. Include verification checklists if applicable

### New Reference Doc (Not Auto-Loaded)
1. Create `rules/my-reference.md` (plain `.md`)
2. No frontmatter needed
3. Reference from `.mdc` files as needed

### New Command
1. Create `commands/category/my-command.md` (use folder hierarchy)
2. Include required sections (Scope, Think Before Acting, Workflow, Follow-Up)
3. Add "Related Commands" cross-references
4. No frontmatter needed

### New Agent
1. Create `agents/my-agent.mdc`
2. Add YAML frontmatter with `name`, `model`, `description`
3. Define domain-specific behavior
4. Reference how it uses CLAUDE.md

---

## File Conventions

- **Rules: `.mdc` for auto-load** - plain `.md` files are reference only
- **Lowercase with hyphens** - `git/commit.md` not `GitCommit.md`
- **Hierarchical folders** - `commands/git/`, `commands/ml/`, etc.
- **Self-documenting names** - purpose clear from filename
- **Cross-reference** - link to related commands/rules
- **AGENT-GENERATED header** - for files agents create in repos

---

## Key Invariants Across All Configs

**Authoritative Safety table:** `~/.cursor/rules/core.mdc`

All rules/commands/agents must respect the Safety section in `core.mdc`. Key points:

- Never `git push/commit` without explicit request
- Never `rm` (backup first) or `scancel -u $USER`
- No try/catch (fail fast), max 4 indent levels
- End with follow-up question, check CLAUDE.md first




