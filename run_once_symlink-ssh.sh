#!/bin/bash
# Chezmoi run_once script: symlink ~/.ssh to Windows host SSH directory.
# Only runs in WSL environments. Runs once per chezmoi state hash change.

set -e

# Only run in WSL
if ! grep -qi microsoft /proc/version 2>/dev/null; then
    echo "Not in WSL, skipping SSH symlink setup."
    exit 0
fi

# Find the Windows username by looking at /mnt/c/Users/
WIN_USER="${WIN_USER:-}"
if [ -z "$WIN_USER" ]; then
    # Try to detect from common locations
    for candidate in /mnt/c/Users/*/; do
        name=$(basename "$candidate")
        # Skip system accounts
        case "$name" in
            Public|Default|"Default User"|"All Users") continue ;;
        esac
        WIN_USER="$name"
        break
    done
fi

if [ -z "$WIN_USER" ]; then
    echo "Could not detect Windows username. Set WIN_USER env var and re-run chezmoi apply."
    exit 1
fi

WIN_SSH="/mnt/c/Users/${WIN_USER}/.ssh"

if [ ! -d "$WIN_SSH" ]; then
    echo "Windows SSH directory not found: $WIN_SSH"
    echo "Create it on Windows first, then re-run chezmoi apply."
    exit 1
fi

# If ~/.ssh already exists and is NOT a symlink, back it up
if [ -d "$HOME/.ssh" ] && [ ! -L "$HOME/.ssh" ]; then
    echo "Backing up existing ~/.ssh to ~/.ssh.wsl-backup"
    mv "$HOME/.ssh" "$HOME/.ssh.wsl-backup"
fi

# Create the symlink
if [ ! -L "$HOME/.ssh" ]; then
    ln -s "$WIN_SSH" "$HOME/.ssh"
    echo "Created symlink: ~/.ssh -> $WIN_SSH"
else
    echo "SSH symlink already in place: ~/.ssh -> $(readlink ~/.ssh)"
fi

# Note: WSL automount metadata must be enabled for correct permissions.
# Add to /etc/wsl.conf:
#   [automount]
#   options = "metadata,umask=22,fmask=11"
# Then restart WSL: wsl --terminate <distro>
