# Command Discovery

When to suggest related commands. Proactively recommend switching to a specialized command when it would better serve the user's needs.

---

## Command Reference

| Command | Purpose | Trigger |
|---------|---------|---------|
| **git-manager** | Staging, committing, branching | User wants to commit, stage files, or manage branches |
| **pr-manager** | Splitting changes into PRs via worktrees | User needs to split a branch into multiple PRs |
| **cherry-pick** | Cherry-picking commits between branches | User needs specific commits from another branch |
| **sweep-manager** | WandB sweeps on Slurm | Training, sweeps, job management |
| **update** | Status check across everything | User asks "what's running?" or wants overview |
| **sync-remote** | Syncing cursor config to remote servers | User mentions remote setup or SSH |
| **handover** | Session handover with unique keys | Session ending, complex WIP to document |
| **continue** | Planning mode context recovery | Starting new session, need context |
| **continue-agentic** | Autonomous execution with context | Ready to execute after planning |
| **ideate** | Generate improvement ideas | User asks "what's next?" or wants roadmap |
| **make-agentic** | Audit/maintain repo-local .cursor/ config | Setting up agentic config in a repo |
| **end-of-day** | Wrap up, handover, overnight job check | End of work session |
| **note** | Persist notes for repo (CLAUDE/notes/) | User wants to save context for later |
| **worktrees** | Discover worktrees and visibility | Questions about worktree context |
| **new-worktree** | Create a new worktree with shared resources | Starting isolated feature work |
| **biohive** | BioHive project workflows | BioHive-specific tasks |

---

## How to Suggest

Use natural language, not command syntax:

**Good:**
> "For committing these changes, I can use git-manager - want me to switch?"
> "This is sweep-related - should I check with sweep-manager?"

**Bad:**
> "Run @git-manager"
> "Execute /sweep-manager command"

---

## Common Transitions

| Current Context | Situation | Suggest |
|-----------------|-----------|---------|
| Any | User wants to commit | → git-manager |
| Any | User asks about running jobs | → sweep-manager or update |
| git-manager | Need to split into PRs | → pr-manager |
| pr-manager | Need specific commits | → cherry-pick |
| Any | Session ending | → handover or end-of-day |
| Any | Starting fresh | → continue or continue-agentic |
| After completing feature | What's next? | → ideate |
| sweep-manager | Need overall status | → update |

---

## When NOT to Suggest

- Don't interrupt focused work with command suggestions
- Don't suggest if user is clearly in the middle of a task
- Don't suggest the same command repeatedly
- If the current command can handle the task, don't switch
