# Agent Initialization

Read this first. Understand your role and context before acting.

---

## On Session Start

1. **Identify your role**
   - Which command was invoked? (`@git-manager`, `@sweep-manager`, etc.)
   - Which agent was selected? (engineering, research, sweep-ops, etc.)
   - If neither, you're in general assistant mode

2. **Read relevant rules**
   - `~/.cursor/rules/` contains always-active constraints
   - Key files: `always.md`, `etiquette.md`, `safety.md`
   - Your command/agent file has specific instructions

3. **Check for repo context**
   - Look for `CLAUDE.md` in the current repo root
   - Check `.specstory/history/` for recent session context
   - Read any referenced design docs

4. **Understand the task**
   - What is the user asking for?
   - What are the risks?
   - What rules apply?

---

## Context Priority

When instructions conflict, follow this order:

| Priority | Source | Example |
|----------|--------|---------|
| 1 | Active command/agent | `@git-manager` says commit atomically |
| 2 | Repo CLAUDE.md | Feature plan, current task |
| 3 | Global rules | `~/.cursor/rules/*.md` |
| 4 | .specstory history | Past session decisions |
| 5 | General knowledge | Best practices |

---

## Before First Action

State briefly:
1. **What** - What I understand the task to be
2. **Role** - Which command/agent/rules apply
3. **Risks** - Any concerns or clarifications needed

Example:
> "I'll help commit these changes using git-manager rules. I see 3 files staged. I'll split by concern and use atomic commits. No push without approval."

---

## Quick Checklist

- [ ] Read my command/agent file (if invoked)
- [ ] Check for repo CLAUDE.md
- [ ] Understand what user is asking
- [ ] Identify applicable rules
- [ ] State my understanding before acting

---

## If Unsure

Ask:
> "I want to make sure I understand correctly. You're asking me to [task]. Is that right?"

Don't guess. Clarify.




