# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a dotfiles repository with dual management systems:
1. **Chezmoi** - Traditional dotfile manager for cross-platform compatibility
2. **NixOS/Home Manager** - Declarative system configuration for reproducible environments

The repository contains shell configurations, terminal emulator setups, window manager configurations, and various development tools that can be deployed using either approach.

## Core Architecture

### Chezmoi Structure
- **Source directory**: `~/.local/share/chezmoi` (default chezmoi source)
- **Destination**: `~` (home directory)
- **External dependencies**: Managed via `.chezmoiexternal.toml`

### Key Components
1. **Shell Configuration**: ZSH with oh-my-zsh, antigen, and pure theme
2. **Terminal**: Kitty terminal with catppuccin themes
3. **Window Manager**: i3 window manager configuration
4. **Status Bar**: Polybar with multiple themes and styles
5. **Editor**: Vim configuration with vim-plug
6. **Multiplexer**: tmux with TPM plugin manager

### External Dependencies
The `.chezmoiexternal.toml` file manages external git repositories and files:
- oh-my-zsh framework
- Pure zsh theme
- tmux plugin manager (TPM)
- vim-plug
- AstroNvim configuration
- Kitty themes
- Polybar themes and scripts
- Autojump directory navigation

## Common Commands

### Chezmoi Operations
```bash
# Apply dotfiles (install/update)
chezmoi apply

# Check what would change
chezmoi diff

# Update from remote repository
chezmoi update

# Add new files to dotfiles
chezmoi add ~/.newconfig

# Edit a managed file
chezmoi edit ~/.bashrc

# Launch shell in source directory
chezmoi cd

# Check system for potential issues
chezmoi doctor
```

### Development Workflow
```bash
# Initialize dotfiles on new machine
sh -c "$(curl -fsLS get.chezmoi.io)"
chezmoi init --apply ctr26/dotfiles

# Configure chezmoi (add name/email)
chezmoi edit-config
```

### NixOS/Home Manager Operations
```bash
# One-command install (auto-detects system type)
curl -sSL https://raw.githubusercontent.com/ctr26/dotfiles/main/install.sh | bash

# Or clone and run locally
git clone https://github.com/ctr26/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh

# Deploy home-manager only (any Linux system with Nix)
nix run .#deploy-home

# Deploy full NixOS system configuration (NixOS only)
nix run .#deploy-system

# Interactive deployment menu
nix run .

# Update flake inputs
nix run .#update

# Enter development shell
nix develop
```

## File Organization

### Naming Convention
- `dot_filename` → `.filename` in home directory
- `executable_filename` → executable `filename`
- `symlink_filename` → symbolic link
- Template files use `.tmpl` extension

### Key Configurations
- **ZSH**: `dot_zshrc.tmpl` with template variables
- **Git**: `dot_gitconfig.tmpl` with user-specific templates
- **tmux**: `dot_tmux.conf` with plugin management
- **Vim**: `dot_vimrc` with vim-plug plugins
- **Bash**: `dot_bashrc` with autojump integration

### Directory Structure
- `dot_config/` → `~/.config/` (XDG config directory)
  - `i3/` → i3 window manager configuration
  - `kitty/` → terminal emulator with themes
  - `polybar/` → status bar with multiple themes
  - `ranger/` → file manager configuration
- `nix/` → NixOS and Home Manager configurations
  - `home.nix` → Home Manager user configuration
  - `configuration.nix` → NixOS system configuration
- `flake.nix` → Nix flake for modern deployment
- `install.sh` → One-command installer script

## Installation Scripts

### Autojump Installation
The `run_onchange_install-autojump.sh` script automatically:
1. Clones autojump repository to `~/.local/share/autojump`
2. Runs the installation script
3. Only runs when the script content changes

## Theme Management

### Polybar Themes
Multiple polybar themes available in `dot_config/polybar/`:
- blocks, colorblocks, cuts, docky, forest, grayblocks
- hack, material, shades, shapes
- Each theme includes bars, colors, modules, and rofi integration

### Kitty Themes
- Catppuccin theme variants (frappe, latte, macchiato, mocha)
- Symlinked theme configuration for easy switching

## Deployment Strategies

### Choose Your Approach

**Chezmoi (Traditional)**
- ✅ Cross-platform (Linux, macOS, Windows)
- ✅ Works on any system with minimal dependencies
- ✅ Mature and stable
- ❌ Manual dependency management
- ❌ Less reproducible

**NixOS/Home Manager (Recommended)**
- ✅ Fully reproducible environments
- ✅ Declarative package management  
- ✅ Atomic updates and rollbacks
- ✅ No dependency conflicts
- ❌ Linux only (NixOS or with Nix package manager)
- ❌ Learning curve for Nix language

### Quick Start Commands

**New Machine Setup:**
```bash
# The fastest way - auto-detects your system
curl -sSL https://raw.githubusercontent.com/ctr26/dotfiles/main/install.sh | bash
```

**NixOS Machine:**
```bash
# Full system configuration
git clone https://github.com/ctr26/dotfiles.git ~/dotfiles
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#nixos
```

**Any Linux with Nix:**
```bash
# Home Manager only
nix run github:ctr26/dotfiles#deploy-home
```

**Traditional Systems:**
```bash
# Chezmoi approach
chezmoi init --apply ctr26/dotfiles
```

## Notes for Development

### Chezmoi Development
- Always use `chezmoi edit` instead of directly editing files in the home directory
- Template files (`.tmpl`) support Go text/template syntax
- External dependencies are refreshed automatically based on `refreshPeriod`
- Use `chezmoi doctor` to diagnose configuration issues

### NixOS Development
- Edit configurations in `nix/` directory
- Test changes: `nixos-rebuild test --flake .#nixos` (doesn't persist)
- Apply changes: `nixos-rebuild switch --flake .#nixos`
- For home-manager only: `home-manager switch --flake .#ctr26`
- Update dependencies: `nix flake update`
- The flake provides apps for common operations (see `nix run .` for menu)