#!/usr/bin/env bash

set -e

echo "🎯 Flexible Dotfiles Installer"
echo "=============================="
echo "User: $USER"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "This script should not be run as root"
fi

# Detect system type
if [ -f /etc/nixos/configuration.nix ]; then
    SYSTEM_TYPE="nixos"
    info "NixOS system detected"
elif command -v nix &> /dev/null; then
    SYSTEM_TYPE="nix"
    info "Nix package manager detected on non-NixOS system"
else
    SYSTEM_TYPE="traditional"
    info "Traditional Linux system detected"
fi

# Install Nix if not present
if [ "$SYSTEM_TYPE" = "traditional" ]; then
    info "Installing Nix package manager..."
    if ! command -v curl &> /dev/null; then
        error "curl is required but not installed. Please install curl first."
    fi
    
    sh <(curl -L https://nixos.org/nix/install) --daemon
    
    # Source nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    
    success "Nix installed successfully"
    SYSTEM_TYPE="nix"
fi

# Enable flakes
info "Enabling Nix flakes..."
mkdir -p ~/.config/nix
if [ ! -f ~/.config/nix/nix.conf ] || ! grep -q "experimental-features.*flakes" ~/.config/nix/nix.conf; then
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
    success "Nix flakes enabled"
else
    info "Nix flakes already enabled"
fi

# Clone or update dotfiles repository
DOTFILES_DIR="$HOME/dotfiles"
if [ -d "$DOTFILES_DIR" ]; then
    info "Dotfiles directory exists, updating..."
    cd "$DOTFILES_DIR"
    git pull
else
    info "Cloning dotfiles repository..."
    git clone https://github.com/ctr26/dotfiles.git "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
fi

success "Dotfiles repository ready"

# Deploy based on system type
case "$SYSTEM_TYPE" in
    "nixos")
        info "Deploying full NixOS configuration..."
        warning "This will require sudo access to rebuild the system"
        echo ""
        read -p "Continue with system rebuild? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd ~/.config/nix
            nix run .#deploy-system
            success "NixOS system configuration deployed!"
        else
            info "Skipping system configuration, deploying home-manager only..."
            cd ~/.config/nix
            nix run .#deploy-home
            success "Home Manager configuration deployed!"
        fi
        ;;
    "nix")
        info "Deploying Home Manager configuration..."
        cd ~/.config/nix
        nix run .#deploy-home
        success "Home Manager configuration deployed!"
        ;;
esac

echo ""
success "🎉 Dotfiles installation complete!"
echo ""
info "What was installed:"
echo "  • ZSH with oh-my-zsh and pure prompt"
echo "  • tmux with catppuccin theme"
echo "  • Vim/Neovim with plugins"
echo "  • Kitty terminal with transparency"
echo "  • Git configuration"
echo "  • Development tools and utilities"

if [ "$SYSTEM_TYPE" = "nixos" ]; then
    echo "  • i3 window manager with polybar"
    echo "  • System-level packages and services"
fi

echo ""
info "Next steps:"
echo "  1. Restart your shell or run: exec \$SHELL"
echo "  2. Update git user info if needed: git config --global user.name 'John Doe'"
echo "  3. Update git user email: git config --global user.email 'john.doe@example.com'"
echo "  4. Authenticate with GitHub: gh auth login"

if [ "$SYSTEM_TYPE" = "traditional" ]; then
    echo "  4. Consider switching to NixOS for full system management!"
fi

echo ""
info "To update your dotfiles in the future:"
echo "  chezmoi update                    # Update all dotfiles"
echo "  cd ~/.config/nix && nix run .    # Deploy NixOS configs"
echo ""
info "Need help? Check the documentation:"
echo "  • README.md for general setup"
echo "  • CLAUDE.md for development info"
echo "  • ~/.config/nix/ directory for NixOS configurations"