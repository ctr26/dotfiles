#!/bin/sh
# chezmoi:template
# Runs whenever this file changes (package list update triggers reinstall)
#
# Global npm packages hash: {{ include "dot_config/npm-packages.txt" | sha256sum }}

set -e

if ! command -v npm >/dev/null 2>&1; then
  echo "npm not found, skipping global package install"
  exit 0
fi

while IFS= read -r pkg || [ -n "$pkg" ]; do
  # Skip comments and blank lines
  case "$pkg" in
    \#*|"") continue ;;
  esac
  echo "Installing $pkg..."
  npm install -g "$pkg" || echo "Failed to install $pkg, continuing..."
done < "{{ .chezmoi.sourceDir }}/dot_config/npm-packages.txt"

echo "Global npm packages up to date."
