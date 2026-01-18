---
tag: ALWAYS
scope: global
---
# Always Rules

These rules apply to EVERY interaction, regardless of context.

## First: Read Init

Before starting any session, read #INIT to understand:
- Available rules and your role
- Context hierarchy (command → repo CLAUDE.md → global rules)
- What to check before first action

## Check for Handover Context

At session start, check for existing handover documents:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
ls "$REPO_ROOT/CLAUDE.md" "$REPO_ROOT/CLAUDE/" 2>/dev/null
```

If found:
- Read `CLAUDE.md` for current handover key and session focus
- Check `CLAUDE/` folder for detailed handover files (e.g., `CLAUDE/HO-*.md`)
- Resume from where the last session left off
- Verify the handover key matches if one was provided

**Important:** Only use the **repo-local** `CLAUDE.md` (in `$REPO_ROOT/`). Never read or write `~/.cursor/CLAUDE.md` - that file is for cursor-config maintenance only.

### Context File Types

| File | Purpose | When to Use |
|------|---------|-------------|
| `CLAUDE.md` | Session index, handover pointer, quick reference | Default - most repos |
| `CLAUDE_SESSION.md` | Extended session state for game dev | Games with complex state |
| `CLAUDE/` folder | Detailed handover files, notes, todos | Long-running features |

## Discover Repo Tooling

Before running commands, check how this repo does things:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
ls "$REPO_ROOT/Makefile" "$REPO_ROOT/justfile" "$REPO_ROOT/scripts/" "$REPO_ROOT/pyproject.toml" 2>/dev/null
```

| If you find | Then use | Not |
|-------------|----------|-----|
| `Makefile` | `make <target>` | raw commands |
| `justfile` | `just <recipe>` | raw commands |
| `scripts/` | `./scripts/foo.sh` | inline scripts |
| `pyproject.toml` with `[tool.uv]` | `uv run`, `uv sync` | `pip install` |
| `pyproject.toml` with `[tool.poetry]` | `poetry run` | `pip install` |
| `.python-version` | respect version | system python |
| `package.json` | `npm run`, `pnpm` | raw node |

**Always check `Makefile` or `justfile` first** - common targets:
- `make test`, `make lint`, `make format`
- `make install`, `make dev`, `make build`
- `make help` to list all targets

**Python projects:** Prefer `uv` if available (fast, handles venvs):
```bash
uv sync          # install deps
uv run pytest    # run in venv
uv add <pkg>     # add dependency
```

## Centralized Config via Host Machine

The host machine's `~/.cursor/` is the single source of truth for rules, commands, and agents. When working on remote machines via SSH tunnel or Cursor Remote, use Cursor's file tools to access host config directly - no syncing required.

| Do | Why |
|----|-----|
| Use `read_file` / `list_dir` for `~/.cursor/*` | Cursor tools access host through tunnel |
| Read rules/commands from host, not remote | One source of truth, no sync needed |
| Inform user if host config is inaccessible | They may need to check tunnel setup |

**Terminal commands** (`cat`, `ls`) only see the remote filesystem - use them for remote files, not for accessing your centralized config.

## Rule Writing Style

When writing or updating rules:

| Prefer | Avoid |
|--------|-------|
| "Check if CLAUDE.md exists in the repo root" | Bash one-liners with `ls` or `test` |
| "Find the repo root using git" | `git rev-parse --show-toplevel` as instructions |
| "Look for Makefile, justfile, or scripts/" | Complex `ls ... 2>/dev/null` chains |

**Why:** Plain English is readable across sessions, doesn't break when paths change, and lets the agent choose the right tool (Cursor file tools vs terminal).

**Exception:** Code blocks are fine for *examples* of what to run, but instructions should be prose.

## Note Infrastructure in CLAUDE.md

When you discover how a repo is set up, document it so future sessions skip re-discovery. Check CLAUDE.md first - only add if not already noted.

**What to look for and note:**

| Category | Examples to check | What to record |
|----------|-------------------|----------------|
| Build system | Makefile, justfile, npm scripts | Key targets (test, lint, build) and any non-obvious conventions |
| Python packaging | uv, poetry, pip, conda | Which tool and any special sync/run patterns |
| HPC / cluster | Slurm configs, sbatch templates, partition files | Partition names, GPU types, memory limits, template locations |
| Environment | .env files, required API keys | Which vars are needed (not the values) |
| CI/CD | GitHub Actions, pre-commit hooks | What runs automatically vs manually |

**Format suggestion for CLAUDE.md:**

```
## Infrastructure
- Build: Makefile (make test, make format)
- Python: uv
- HPC: Slurm gpu partition, A100s, templates in slurm/
- Required env: WANDB_API_KEY, HF_TOKEN
```

**When to document:** After first discovering infrastructure, or when you learn something non-obvious (e.g., "use `make test-fast` for quick iteration, `make test` runs full suite").

## Before ANY Action

**See #CORE for the authoritative Safety table.**

Quick mental check: Push? Commit? Delete? Slurm? Slow command? → Stop and verify.

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

## Report File Access Issues

**Never silently ignore inaccessible files.** When a file or folder can't be accessed:

| Issue | Action |
|-------|--------|
| Permission denied | Report the file and suggest symlink command |
| File not found | Confirm path, ask if user meant something else |
| Ignored by `.cursorignore` | Explain why and offer workaround |
| Binary/unreadable | State it clearly, don't pretend you read it |

Example response:
> "Couldn't access `/path/to/file.txt` - permission denied. Want me to provide a symlink command?"

## Always End With a Question

**Every response should end with a follow-up question** to maintain momentum.

### General Patterns

| Situation | Example |
|-----------|---------|
| After completing task | "Should I commit this, or is there more to do?" |
| After showing status | "What needs attention first?" |
| After explaining | "What would you like to work on?" |
| Unclear request | "Could you clarify what you'd like me to focus on?" |
| Errors found | "Want me to analyze these errors and suggest fixes?" |
| Everything looks good | "Anything specific you'd like me to check?" |

### Domain-Specific Examples

| Domain | Example Questions |
|--------|-------------------|
| Git commits | "Push to origin? Or stage more files first?" |
| PR/worktree work | "Ready to cherry-pick commits? Which should go in this PR?" |
| Sweeps/training | "Want to resume the preempted jobs, or check logs first?" |
| Ideation | "Which ideas should we explore further?" |
| End of day | "Want to commit before leaving, or keep as WIP?" |

**Default:** "What would you like to do next?"

Commands may include 1-2 additional domain-specific examples, but should not duplicate this full table.

## Rule Discovery

When reading CLAUDE.md or .specstory history, watch for repeated patterns:
- Preferences stated multiple times
- Corrections given more than once
- Workflow patterns that recur

**If you notice a pattern, ask:**
> "I've seen [pattern] come up a few times. Want me to add this as a rule?"

## Learn from Mistakes

When you make a mistake or receive a correction, **document it** so future sessions don't repeat it:

| Trigger | Action |
|---------|--------|
| User corrects your approach | Add note to CLAUDE.md under "Lessons Learned" |
| Command fails unexpectedly | Document the fix in CLAUDE/ folder |
| You misunderstand a repo pattern | Update CLAUDE.md with the correct pattern |
| Repeated correction (2+ times) | Propose adding as a new rule |
| Pattern found in .specstory history | Propose rule or add to CLAUDE.md |

**Proactively mine history:** When starting a session, scan `.specstory/history/` and `.cursor/plans/` for recurring corrections, decisions, or preferences and propose rules.

**Format for CLAUDE.md:**
```
## Lessons Learned
- [date] Don't use X, use Y instead because [reason]
- [date] This repo prefers [pattern] over [alternative]
```

**For significant learnings:** Create `CLAUDE/lessons.md` in the repo root.

> "I made an error here. Let me add this to CLAUDE.md so we don't hit this again."

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
> "Want me to review CLAUDE.md? It might have stale notes or outdated state."

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

## Chat Length Awareness

When a chat grows too long, suggest handover to preserve context quality.

### Triggers for Handover

| Signal | Action |
|--------|--------|
| 15+ message exchanges | Suggest: "This chat is getting long - want me to `/handover`?" |
| Major task boundary | Suggest handover before starting a new unrelated task |
| Context confusion | If you lose track of earlier decisions, handover immediately |
| Complex multi-step done | Proactively offer handover to capture state |

### Planning Mode Handover

When in planning mode (plan not yet executed), guide the user to spawn a fresh agent:

1. Create the handover document via `/handover`
2. Provide the startup prompt with the handover key
3. Suggest: "Open a new Cursor tab and paste the startup prompt to continue with a fresh agent"

This ensures the next agent starts clean with full context from the handover file.

### Example

> "We've covered a lot of ground here (20+ messages). I recommend:
> 1. I'll create a handover now
> 2. Open a new Cursor tab  
> 3. Paste the startup prompt I provide
> 
> This gives the next agent fresh context. Continue here or handover?"

## Worktrees for Large Changes

For large codebase changes, suggest worktrees:
> "This is a significant change. Want to use a worktree to isolate it?"

Benefits:
- Isolated from main branch
- Can switch back without stashing
- Parallel work on multiple features

Use the worktree creation script to create with symlinked resources.

## Code Style

- Max 4 indentation levels (refactor if deeper)
- No try/catch (fail fast for research code)
- Match existing repo patterns
- Prefer additive changes over modifications

