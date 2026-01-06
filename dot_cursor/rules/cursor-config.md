# Cursor Configuration Reference

How rules, commands, and agents are built in `~/.cursor/`.

---

## Directory Structure

```
~/.cursor/
├── rules/          # Always-active behavior (*.md)
├── commands/       # User-triggered workflows (*.md)
└── agents/         # Specialized personas (*.mdc)
```

| Folder | Extension | Activation | Purpose |
|--------|-----------|------------|---------|
| `rules/` | `.md` | Always on | Background constraints, style rules |
| `commands/` | `.md` | User invokes (`@command`) | Task-specific workflows |
| `agents/` | `.mdc` | User selects | Specialized personas with model config |

---

## Rules (`rules/*.md`)

Rules apply to every interaction automatically. No frontmatter needed.

### Naming Convention
- Lowercase with hyphens: `code-style.md`, `safety.md`
- Names should be self-descriptive

### Standard Sections

```markdown
# Rule Name

## CRITICAL / Never Do
| Rule | Why |
|------|-----|
| Never `git push` | User controls remote |

## Always Do
- Check CLAUDE.md first
- End with follow-up question

## Verification Checklist
- [ ] Check before action
- [ ] Backup before delete
```

### Current Rules
| File | Purpose |
|------|---------|
| `always.md` | Core invariants (think before acting, response style) |
| `etiquette.md` | Comprehensive agent behavior guide |
| `code-style.md` | Formatting, architecture, git commits |
| `safety.md` | Destructive action prevention |
| `workflow.md` | Patterns extracted from commands |

---

## Commands (`commands/*.md`)

Commands are user-triggered workflows. Invoke with `@command-name`.

### Naming Convention
- Lowercase with hyphens: `git-manager.md`, `sweep-manager.md`
- Use `-manager` suffix for management tasks

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
| File | Purpose |
|------|---------|
| `etiquette.md` | Core rules reference (same as rule) |
| `git-manager.md` | Staging, committing, branching |
| `handover.md` | Session handover with unique keys |
| `pr-manager.md` | Split changes into PRs via worktrees |
| `cherry-pick.md` | Cherry-pick commits between branches |
| `sweep-manager.md` | WandB sweeps on Slurm |
| `update.md` | Comprehensive status check |
| `sync-remote.md` | Sync config to remote servers |
| `continue.md` | Resume previous work |
| `ideate.md` | Brainstorming/planning mode |

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

### New Rule
1. Create `rules/my-rule.md`
2. Add "Never Do" and "Always Do" sections
3. Include verification checklists if applicable
4. No frontmatter needed

### New Command
1. Create `commands/my-command.md`
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

- **Markdown only** - no JSON/YAML config files for content
- **Lowercase with hyphens** - `git-manager.md` not `GitManager.md`
- **Self-documenting names** - purpose clear from filename
- **Cross-reference** - link to related commands/rules
- **AGENT-GENERATED header** - for files agents create in repos

---

## Key Invariants Across All Configs

These rules appear everywhere - enforce consistency:

1. **Never `git push`** - user controls remote
2. **Never `git commit` without request** - user decides when
3. **Never `rm`** - backup first
4. **Never cancel all Slurm jobs** - check first
5. **No try/catch** - fail fast (research code)
6. **Max 4 indent levels** - refactor to functions
7. **End with follow-up question** - maintain momentum
8. **Check CLAUDE.md first** - read context before acting




