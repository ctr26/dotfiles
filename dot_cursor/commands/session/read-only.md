# Read-Only Mode

Observer mode. Explicitly restricts agent to read-only tools.

---

## When to Use

- Code review without risk of accidental changes
- Learning an unfamiliar codebase
- Auditing without side effects
- Pre-meeting codebase exploration
- Answering questions about code structure

---

## Allowed Tools

| Tool | Purpose |
|------|---------|
| `read_file` | View file contents |
| `grep` | Search file contents |
| `glob_file_search` | Find files by pattern |
| `list_dir` | Browse directories |
| `ask_question` | Structured queries to user |

---

## Forbidden Tools

| Tool | Why Forbidden |
|------|---------------|
| `write` | Modifies files |
| `search_replace` | Modifies files |
| `run_terminal_cmd` | Except whitelist below |
| `todo_write` | Modifies state |
| `delete_file` | Destructive |

---

## Terminal Whitelist

Only these read-only commands are permitted:

```bash
# Git (read-only)
git status
git log [options]
git diff [options]
git show [ref]
git branch -a
git stash list

# File viewing
cat [file]
head [file]
tail [file]
less [file]

# Directory listing
ls [options] [path]
tree [path]
find [path] -name [pattern]

# Text search
grep [pattern] [files]
rg [pattern] [path]

# Stats
wc [file]
du -sh [path]
```

---

## Forbidden Terminal Commands

| Command | Risk |
|---------|------|
| `git commit` | Modifies repo |
| `git push` | Modifies remote |
| `git checkout` | Changes branch |
| `git reset` | Destructive |
| Any write command | Modifies system |
| `rm`, `mv`, `cp` | File operations |
| Package managers | System changes |

---

## Entering Read-Only Mode

When user invokes `/session/read-only`:

1. Acknowledge the constraint explicitly
2. Gather context using allowed tools only
3. Present findings
4. Answer questions without making changes

Example acknowledgment:

> **Read-only mode active.** I can explore the codebase and answer questions, but won't make any changes. Use `/session/continue` or `/session/agentic` when ready to edit.

---

## Gather Context (Read-Only)

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
echo "=== Read-Only Exploration ==="
echo "Repo: $REPO_ROOT"
git branch --show-current 2>/dev/null
git status --short 2>/dev/null | head -10
ls -la 2>/dev/null | head -15
```

---

## Answering Questions

In read-only mode, focus on:

| Question Type | Response Pattern |
|---------------|------------------|
| "How does X work?" | Read relevant files, explain |
| "Where is Y defined?" | Use grep/glob to find, show location |
| "What does this file do?" | Read and summarize |
| "What's the architecture?" | Read multiple files, synthesize |
| "Any issues here?" | Analyze without fixing |

---

## Exiting Read-Only Mode

Read-only mode ends when user:

1. Explicitly requests edits ("fix this", "change that")
2. Invokes a different command (`/session/continue`, etc.)
3. Says "exit read-only mode"

When exiting, acknowledge:

> **Exiting read-only mode.** Ready to make changes.

---

## Error Handling

If user asks for changes while in read-only mode:

```
ask_question(
  title="You're in read-only mode. How should I proceed?",
  options=[
    {"id": "exit", "label": "Exit read-only mode and make the change"},
    {"id": "explain", "label": "Just explain what I would change"},
    {"id": "stay", "label": "Stay read-only, I'll do it myself"}
  ]
)
```

---

## Use Cases

### Code Review
- Read the diff: `git diff main..feature`
- Analyze changes without touching code
- Provide feedback as comments

### Learning Codebase
- Explore directory structure
- Read key files (README, main entry points)
- Trace function calls through grep
- Build mental model without risk

### Pre-Meeting Prep
- Quick orientation on recent changes
- Understand what the code does
- Prepare talking points

### Audit
- Check for patterns/anti-patterns
- Verify compliance with rules
- Document findings without modifying

---

## Related Commands

| Need | Use Instead |
|------|-------------|
| Context recovery + planning | → `/session/continue` |
| Quick orientation | → `/session/catch-up` |
| Autonomous execution | → `/session/agentic` |

