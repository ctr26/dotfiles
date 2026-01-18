---
requestsAgent: worktree-ops
---

# New Worktree

You help create git worktrees for feature isolation.

## Session Scope

Worktree creation only. For worktree context/visibility, use `@worktrees`.

For detailed symlink patterns and conventions, see #GIT-WORKTREE.

---

## When to Use

- Large codebase changes
- Multi-session features
- Parallel feature development
- When you need to switch between features without stashing

---

## Think Before Acting

Before creating:
1. Confirm branch name and purpose
2. Check if worktree already exists: `git worktree list`
3. Verify we're in a git repo: `git rev-parse --show-toplevel`

---

## Workflow

### 1. Gather Info

Ask for:
- Branch name (e.g., `feat/auth`)
- Purpose (one-line description)
- Path (optional, defaults to `worktrees/<branch>`)

### 2. Check Existing Worktrees

```bash
git worktree list
```

### 3. Create Worktree

```bash
~/.cursor/scripts/new-worktree.sh <branch-name> [path]
```

The script:
- Creates worktree with new branch
- Symlinks: `.env`, `.envrc`, `.python-version`, `node_modules`, `.cache`
- Copies: `.venv`, `venv` (to avoid breaking the original)
- Creates fresh `CLAUDE.md` in the worktree

### 4. Update Tracking

Add entry to `~/.cursor/CLAUDE/worktrees/README.md`:

```markdown
| worktrees/<branch> | <branch> | <purpose> | active |
```

### 5. Report

```
Worktree created: worktrees/<branch>
Branch: <branch>
Symlinked: .env, .python-version (if present)
Copied: .venv (if present)
CLAUDE.md: created for feature context

Next: cd worktrees/<branch>
```

---

## Always End With a Follow-Up Question

| Situation | Question |
|-----------|----------|
| Worktree created | "Worktree ready. Want to open it in a new Cursor window?" |
| Branch already exists | "Branch exists. Create worktree from existing branch, or pick a new name?" |
| Error during creation | "Creation failed. Want me to check what went wrong?" |

---

## Related Commands

| Need | Command |
|------|---------|
| Worktree context/visibility | → **git/worktrees** |
| PR management with worktrees | → **git/pr** |
| Session handover | → **session/handover** |
| Check overall status | → **update** |
