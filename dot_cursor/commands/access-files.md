# access-files

Create symlinks so agents can read outside-repo files via the workspace.

> **Sandbox Note:** This command creates symlinks to files outside the repo (like `~/.cursor/`).
> Sandboxed agents cannot read these paths directly. The symlink approach lets you:
> 1. Run this command in a real terminal (not sandboxed)
> 2. Then the agent can read the symlinked content from within the workspace

## Usage

```bash
# Create external/ directory in your repo
mkdir -p "<REPO_ROOT>/external"

# Symlink files you want the agent to access
ln -sfn "$HOME/.specstory" "<REPO_ROOT>/external/specstory"

# Generic template
ln -sfn "/ABSOLUTE/PATH/OUTSIDE/REPO" "<REPO_ROOT>/external/NAME"
```

After running, the agent can read symlinked content from within the workspace.

## Alternative: Paste Content

If you can't create symlinks, just paste the file contents when the agent asks for them.
The agent should ask: "I can't access ~/.cursor/rules/. Could you paste the relevant content?"
