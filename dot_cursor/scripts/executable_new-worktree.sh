#!/bin/bash
# Create a new git worktree with proper resource setup
# Usage: new-worktree.sh <branch-name> [path]

set -e

BRANCH_NAME="$1"
WORKTREE_PATH="${2:-worktrees/$BRANCH_NAME}"

if [ -z "$BRANCH_NAME" ]; then
    echo "Usage: new-worktree.sh <branch-name> [path]"
    exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
    echo "Error: Not in a git repository"
    exit 1
fi

FULL_PATH="$REPO_ROOT/$WORKTREE_PATH"

# Check if worktree already exists
if git worktree list | grep -q "$FULL_PATH"; then
    echo "Error: Worktree already exists at $FULL_PATH"
    exit 1
fi

# Create parent directory if needed
mkdir -p "$(dirname "$FULL_PATH")"

# Create worktree with new branch from current HEAD
echo "Creating worktree at $WORKTREE_PATH on branch $BRANCH_NAME..."
git worktree add "$FULL_PATH" -b "$BRANCH_NAME"

# Resources to symlink (shared)
SYMLINK_RESOURCES=".env .envrc .python-version node_modules .cache"

# Resources to copy (isolated to avoid breaking original)
COPY_RESOURCES=".venv venv"

echo ""
echo "Setting up resources..."

# Symlink shared resources
for resource in $SYMLINK_RESOURCES; do
    if [ -e "$REPO_ROOT/$resource" ]; then
        ln -sfn "$REPO_ROOT/$resource" "$FULL_PATH/$resource"
        echo "  Symlinked: $resource"
    fi
done

# Copy venv resources (to avoid breaking the original)
for resource in $COPY_RESOURCES; do
    if [ -d "$REPO_ROOT/$resource" ]; then
        echo "  Copying: $resource (this may take a moment)..."
        cp -r "$REPO_ROOT/$resource" "$FULL_PATH/$resource"
        echo "  Copied: $resource"
    fi
done

# Create fresh CLAUDE.md for the worktree
cat > "$FULL_PATH/CLAUDE.md" << EOF
<!-- AGENT-GENERATED: Do not commit to git unless explicitly requested -->
# CLAUDE.md - $BRANCH_NAME

**Branch:** $BRANCH_NAME
**Worktree:** $WORKTREE_PATH
**Created:** $(date +%Y-%m-%d)

---

## Purpose

<!-- Describe the feature/task this worktree is for -->

---

## Plan

<!-- Document your plan here -->

---

## Notes

<!-- Session notes and decisions -->
EOF

echo "  Created: CLAUDE.md"

echo ""
echo "Worktree ready: $WORKTREE_PATH"
echo "Branch: $BRANCH_NAME"
echo ""
echo "Next: cd $WORKTREE_PATH"

