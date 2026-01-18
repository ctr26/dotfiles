---
tag: DISCOVERY
---
# Command Discovery

When to suggest related commands. Proactively recommend switching to a specialized command when it would better serve the user's needs.

---

## Command Reference

| Command | Purpose | Trigger |
|---------|---------|---------|
| **git/commit** | Staging, committing, branching | User wants to commit, stage files, or manage branches |
| **git/pr** | Splitting changes into PRs via worktrees | User needs to split a branch into multiple PRs |
| **git/cherry-pick** | Cherry-picking commits between branches | User needs specific commits from another branch |
| **git/worktrees** | Discover worktrees and visibility | Questions about worktree context |
| **git/worktree** | Create a new worktree with shared resources | Starting isolated feature work |
| **ml/sweep** | WandB sweeps on Slurm | Training, sweeps, job management |
| **session/handover** | Session handover with unique keys | Session ending, complex WIP to document |
| **session/continue** | Planning mode context recovery | Starting new session, need context |
| **session/agentic** | Autonomous execution with context | Ready to execute after planning |
| **session/eod** | Wrap up, handover, overnight job check | End of work session |
| **sync/remote** | Syncing cursor config to remote servers | User mentions remote setup or SSH |
| **setup/agentic** | Audit/maintain repo-local .cursor/ config | Setting up agentic config in a repo |
| **project/biohive** | BioHive project workflows | BioHive-specific tasks |
| **update** | Status check across everything | User asks "what's running?" or wants overview |
| **ideate** | Generate improvement ideas | User asks "what's next?" or wants roadmap |
| **note** | Persist notes for repo (CLAUDE/notes/) | User wants to save context for later |
| **todo** | Manage todos for this repo | Task tracking and prioritization |
| **audit** | Committee review of cursor config | User wants multi-agent review of rules/commands/agents |

---

## How to Suggest

Use natural language, not command syntax:

**Good:**
> "For committing these changes, I can use git/commit - want me to switch?"
> "This is sweep-related - should I check with ml/sweep?"

**Bad:**
> "Run @git/commit"
> "Execute /ml/sweep command"

---

## Common Transitions

| Current Context | Situation | Suggest |
|-----------------|-----------|---------|
| Any | User wants to commit | → git/commit |
| Any | User asks about running jobs | → ml/sweep or update |
| git/commit | Need to split into PRs | → git/pr |
| git/pr | Need specific commits | → git/cherry-pick |
| Any | Session ending | → session/handover or session/eod |
| Any | Starting fresh | → session/continue or session/agentic |
| After completing feature | What's next? | → ideate |
| ml/sweep | Need overall status | → update |

---

## When NOT to Suggest

- Don't interrupt focused work with command suggestions
- Don't suggest if user is clearly in the middle of a task
- Don't suggest the same command repeatedly
- If the current command can handle the task, don't switch
