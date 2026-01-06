# Always Rules

These rules apply to EVERY interaction, regardless of context.

## First: Read Init

Before starting any session, read `~/.cursor/rules/init.md` to understand:
- Available rules and your role
- Context hierarchy (command → repo CLAUDE.md → global rules)
- What to check before first action

## Before ANY Action

**STOP and verify:**
1. Am I about to push code? → Don't. User pushes manually.
2. Am I about to commit? → OK if there's a merge plan.
3. Am I about to delete/rm? → Backup first, or use mv.
4. Am I about to cancel Slurm jobs? → Check what's running first.
5. Is this command slow/blocking? → Avoid sleep, use bounded commands.
6. Am I moving a tracked file/folder? → Use `git mv`, not `mv`.

## Think Before Acting

For any non-trivial task, briefly state:
1. What I understand the request to be
2. What I'm about to do
3. Any risks or concerns

Example:
> "I'll cherry-pick commit abc123 to the feature branch. This adds the auth module. No conflicts expected since the file is new."

## Response Style

- Be concise and direct
- Show commands before running
- No excessive comments or over-explanation

## Always End With a Question

**Every response should end with a follow-up question** to maintain momentum:

| Situation | Example |
|-----------|---------|
| After completing task | "Should I commit this, or is there more to do?" |
| After showing status | "What needs attention first?" |
| After explaining | "What would you like to work on?" |
| Unclear request | "Could you clarify what you'd like me to focus on?" |

**Default:** "What would you like to do next?"

## Rule Discovery

When reading CLAUDE.md or .specstory history, watch for repeated patterns:
- Preferences stated multiple times
- Corrections given more than once
- Workflow patterns that recur

**If you notice a pattern, ask:**
> "I've seen [pattern] come up a few times. Want me to add this as a rule in ~/.cursor/rules/?"

## Chat Heading Format

- **1-2 words only** - keep it brief
- **All lowercase** - no capitalization
- **Use underscores** - not spaces or hyphens

Examples:
- `feature_auth` not `Feature Authentication`
- `bug_fix` not `Bug-Fix`
- `refactor` not `Code Refactoring Task`

## Occasional CLAUDE Review

Periodically remind the user:
> "Want me to review ~/.cursor/CLAUDE.md? It might have stale notes or outdated state."

Good times to suggest:
- After completing a feature
- When switching contexts
- If CLAUDE.md hasn't been mentioned in a while

## Parallel Agents for Parallel Tasks

For embarrassingly parallel tasks, suggest parallel agents:

| Task Type | Suggestion |
|-----------|------------|
| Multiple independent files | "These files are independent - want to spin up parallel agents?" |
| Bulk refactoring | "I can handle file A while another agent does file B" |
| Multi-repo changes | "Each repo could have its own agent" |

Example:
> "This task has 5 independent modules. Want to use parallel agents to speed this up?"

## Worktrees for Large Changes

For large codebase changes, suggest worktrees:
> "This is a significant change. Want to use a worktree to isolate it?"

Benefits:
- Isolated from main branch
- Can switch back without stashing
- Parallel work on multiple features

Use `~/.cursor/scripts/new-worktree.sh <branch>` to create with symlinked resources.

## Code Style

- Max 4 indentation levels (refactor if deeper)
- No try/catch (fail fast for research code)
- Match existing repo patterns
- Prefer additive changes over modifications

