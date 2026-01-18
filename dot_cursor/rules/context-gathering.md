---
tag: CONTEXT
scope: global
---
# Context Gathering

Standard patterns for gathering repo and session context. Use these snippets at the start of any command that needs to understand the current environment.

---

## Repo Root & Worktree Detection

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Detect worktree context
GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "$GIT_COMMON_DIR" ] && [ -n "$GIT_COMMON_DIR" ]; then
    MAIN_REPO=$(dirname "$GIT_COMMON_DIR")
    echo "=== WORKTREE DETECTED ==="
    echo "Worktree: $REPO_ROOT"
    echo "Main repo: $MAIN_REPO"
else
    echo "Working in main repo: $REPO_ROOT"
fi
```

---

## Git Status Snapshot

```bash
git status --short
git log --oneline -5
git branch --show-current
```

---

## Planning Files Check

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Check for CLAUDE.md (in current worktree or main repo)
[ -f "$REPO_ROOT/CLAUDE.md" ] && echo "Found: CLAUDE.md"
[ -d "$REPO_ROOT/CLAUDE" ] && echo "Found: CLAUDE/ folder"
[ -f "$REPO_ROOT/CLAUDE_SESSION.md" ] && echo "Found: CLAUDE_SESSION.md"

# SpecStory trail
ls -lt "$REPO_ROOT/.specstory/history/"*.md 2>/dev/null | head -5
```

---

## WandB Environment (for ML projects)

```bash
WANDB_ENTITY=${WANDB_ENTITY:-$(grep -oP 'entity:\s*\K\S+' wandb/settings 2>/dev/null || echo "TBD")}
WANDB_PROJECT=${WANDB_PROJECT:-$(grep -oP 'project:\s*\K\S+' wandb/settings 2>/dev/null || echo "TBD")}

[ -f .env ] && source .env
[ -f config.env ] && source config.env

echo "WandB: $WANDB_ENTITY/$WANDB_PROJECT"
```

---

## Full Context Gathering (Combined)

Use this for commands that need comprehensive context:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$REPO_ROOT"

# Detect worktree
GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
if [ "$GIT_DIR" != "$GIT_COMMON_DIR" ] && [ -n "$GIT_COMMON_DIR" ]; then
    MAIN_REPO=$(dirname "$GIT_COMMON_DIR")
    echo "Worktree: $REPO_ROOT | Main: $MAIN_REPO"
fi

# Git state
echo "Branch: $(git branch --show-current)"
git status --short
git log --oneline -5

# Planning files
ls CLAUDE.md CLAUDE_SESSION.md CLAUDE/ .cursor/feature.md PR.md 2>/dev/null
ls -lt .specstory/history/*.md 2>/dev/null | head -5
```

---

## Agent Name Derivation

Derive a sensible name for the agent based on context. Priority: Command > Branch > Folder.

```bash
# Derive agent name
if [ -n "$CURSOR_COMMAND" ]; then
  AGENT_NAME="${CURSOR_COMMAND#/}"  # e.g., "sweep-manager"
elif git rev-parse --git-dir &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "dev" ] || [ "$BRANCH" = "master" ]; then
    AGENT_NAME=$(basename "$(git rev-parse --show-toplevel)")
  else
    AGENT_NAME="$BRANCH"
  fi
else
  AGENT_NAME=$(basename "$PWD")
fi
echo "Agent: $AGENT_NAME"
```

| Context | Agent Name | Example |
|---------|------------|---------|
| Using a command | Command name (without `/`) | `sweep-manager`, `git-manager` |
| Feature branch | Branch name | `feat/data-loader`, `fix/auth` |
| Main/dev branch | Repo folder name | `biohive`, `cursor-config` |
| No git | Folder name | `scripts`, `agent` |

---

## When to Use

| Command Type | What to Gather |
|--------------|----------------|
| Git operations | Repo root, branch, status |
| Planning/continue | Full context including CLAUDE.md |
| Sweep/training | Add WandB environment |
| Handover | Full context + specstory + agent name |
