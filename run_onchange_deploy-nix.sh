#!/usr/bin/env bash

# This script deploys NixOS/Home Manager configurations when they change
# It only runs when the nix configuration files are modified

# Skip this script when running through home-manager deployment
# to avoid circular dependencies
if [ -n "$IN_NIX_SHELL" ] || [ -n "$__HM_SESS_VARS_SOURCED" ]; then
    echo "Skipping NixOS deployment (already in Nix environment)"
    exit 0
fi

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
}

# Check if Nix is available
if ! command -v nix &> /dev/null; then
    warning "Nix not found. Skipping NixOS deployment."
    warning "To use NixOS configurations:"
    echo "  1. Install Nix: sh <(curl -L https://nixos.org/nix/install) --daemon"
    echo "  2. Enable flakes: echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf"
    echo "  3. Run: cd ~/.config/nix && nix run .#deploy-home"
    exit 0
fi

# Enable flakes if not already enabled
mkdir -p ~/.config/nix
if [ ! -f ~/.config/nix/nix.conf ] || ! grep -q "experimental-features.*flakes" ~/.config/nix/nix.conf; then
    info "Enabling Nix flakes..."
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# Change to nix configuration directory
cd ~/.config/nix

info "NixOS configurations updated, checking deployment options..."

# Check system type and deploy accordingly
if [ -f /etc/nixos/configuration.nix ]; then
    info "NixOS system detected"
    echo ""
    echo "Choose deployment option:"
    echo "1) Home Manager only (safe, no sudo required)"
    echo "2) Full system rebuild (requires sudo)"
    echo "3) Skip deployment"
    echo ""
    read -p "Enter choice (1-3) [default: 1]: " choice
    choice=${choice:-1}
    
    case $choice in
        1)
            info "Deploying Home Manager configuration..."
            nix run .#deploy-home
            success "Home Manager deployed!"
            ;;
        2)
            info "Deploying full NixOS system configuration..."
            nix run .#deploy-system
            success "System configuration deployed!"
            ;;
        3)
            info "Skipping deployment"
            ;;
        *)
            warning "Invalid choice, deploying Home Manager only"
            nix run .#deploy-home
            ;;
    esac
else
    info "Non-NixOS system detected, deploying Home Manager only..."
    nix run .#deploy-home
    success "Home Manager deployed!"
fi

info "NixOS deployment complete!"
info "Your Nix configurations are now active and managed by chezmoi."