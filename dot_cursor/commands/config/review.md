# Config Review

Review the `~/.cursor` configuration for inconsistencies, redundancy, and improvements.

**When to use:** Periodically audit your rules, commands, and agents for quality.

---

## Session Scope

| In Scope | Redirect To |
|----------|-------------|
| Reviewing rules, commands, agents | This command |
| Making edits to config files | Manual editing after review |
| Creating new rules/commands | → `cursor-config.md` reference |

---

## Think Before Acting

Before reviewing, state:
1. **Scope** - Full review or partial (rules/commands/agents only)?
2. **Focus** - Any specific concern (ML patterns, git workflow, DX)?
3. **Output** - Where to save the review report?

---

## Workflow

### 1. Gather Files

```bash
# Count files to review
echo "Rules: $(find ~/.cursor/rules -name '*.md' -o -name '*.mdc' 2>/dev/null | wc -l)"
echo "Commands: $(find ~/.cursor/commands -name '*.md' 2>/dev/null | wc -l)"
echo "Agents: $(find ~/.cursor/agents -name '*.mdc' 2>/dev/null | wc -l)"
```

### 2. Scope Selection

Use `ask_question` to confirm scope:

```
ask_question(
  title="Review Scope",
  options=[
    {"id": "full", "label": "Full review (rules + commands + agents)"},
    {"id": "rules", "label": "Rules only (~/.cursor/rules/)"},
    {"id": "commands", "label": "Commands only (~/.cursor/commands/)"},
    {"id": "agents", "label": "Agents only (~/.cursor/agents/)"},
    {"id": "ml", "label": "ML-related files only"},
    {"id": "git", "label": "Git-related files only"}
  ]
)
```

### 3. Apply Review Lenses

For each file, apply three lenses:

| Lens | Questions to Ask |
|------|------------------|
| **ML Engineer** | HPC patterns complete? Resource limits documented? |
| **ML Scientist** | Fail-fast enforced? Reproducibility covered? |
| **RSE/DX** | Content DRY? Cross-refs valid? Terminology consistent? |

### 4. Surface Issues

For each finding, use `ask_question` with options:
- Keep as-is
- Strengthen
- Simplify
- Consolidate
- Remove

**Limit:** 5-7 questions per batch.

### 5. Synthesize Findings

After all questions answered, produce summary report.

---

## Issue Types

| Type | Detection | Example |
|------|-----------|---------|
| **Inconsistency** | Same concept, different phrasing | "max 4 indent" vs "keep nesting low" |
| **Rambling** | Prose that should be table | Long paragraphs explaining options |
| **Redundancy** | Duplicated across files | Same "Never Do" in 3 places |
| **Gaps** | Missing coverage | HPC docs but no node exclusions |
| **Conflicts** | Contradictory rules | "fail fast" vs "handle errors" |
| **Stale** | Outdated references | Old command names |

---

## Output Format

Save review report to `~/.cursor/CLAUDE/review-{YYYYMMDD}.md`:

```markdown
## Config Review - [Date]

### Scope
- [What was reviewed]

### Files Reviewed
| Category | Count |
|----------|-------|
| Rules | N |
| Commands | N |
| Agents | N |

### Issues by Type
| Type | Count | Resolution |
|------|-------|------------|
| Inconsistency | N | [actions taken] |
| Rambling | N | ... |

### High Priority Recommendations
1. [Most impactful]
2. [Second most]

### Cross-Cutting Themes
- [Patterns observed]
```

---

## Partial Review Shortcuts

| User Says | Scope |
|-----------|-------|
| "review rules" | `~/.cursor/rules/` only |
| "review ml stuff" | Files with ML/training/sweep/slurm keywords |
| "review git commands" | `commands/git/` + git-related rules |
| "quick review" | High-level scan, major issues only |

---

## Never Do

- Make edits during review - only surface issues
- Skip `ask_question` for discrete choices
- Review without applying all three lenses
- Ignore stale command references
- Overwhelm with too many questions at once

---

## Related Commands

| Situation | Suggest |
|-----------|---------|
| Want to create new rule | → `cursor-config.md` reference |
| Need session handover | → **session/handover** |
| Want to ideate improvements | → **ideate** |

---

## Example Follow-Up

After reviewing:
- "Which issues should we address first?"
- "Want me to draft the edits for the high-priority items?"
- "Should I save this review to CLAUDE/?"

