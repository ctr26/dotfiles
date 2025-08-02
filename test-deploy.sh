#!/usr/bin/env bash

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

echo "🧪 Testing Dotfiles Deployment in Vagrant"
echo "=========================================="
echo ""

# Detect environment
if [ -f /etc/nixos/configuration.nix ]; then
    SYSTEM_TYPE="nixos"
    info "Testing on NixOS system"
elif command -v apt-get &> /dev/null; then
    SYSTEM_TYPE="ubuntu"
    info "Testing on Ubuntu system"
else
    SYSTEM_TYPE="unknown"
    info "Testing on unknown system"
fi

echo ""
echo "Available test scenarios:"
echo "1) Test chezmoi installation (traditional)"
echo "2) Test Nix Home Manager deployment (NixOS only)"
echo "3) Test unified install.sh script"
echo "4) Test all deployment methods"
echo ""

read -p "Enter choice (1-4) [default: 4]: " choice
choice=${choice:-4}

case $choice in
    1)
        info "Testing chezmoi installation..."
        if command -v chezmoi &> /dev/null; then
            success "chezmoi already installed"
        else
            info "Installing chezmoi..."
            sh -c "$(curl -fsLS get.chezmoi.io)"
        fi
        
        info "Initializing dotfiles with chezmoi..."
        chezmoi init --apply /home/$(whoami)/dotfiles
        success "Chezmoi deployment completed"
        ;;
        
    2)
        if [ "$SYSTEM_TYPE" != "nixos" ]; then
            error "Nix Home Manager test only available on NixOS"
            exit 1
        fi
        
        info "Testing Nix Home Manager deployment..."
        info "Enabling Nix flakes..."
        mkdir -p ~/.config/nix
        echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
        
        info "Deploying with Home Manager..."
        cd ~/.config/nix
        nix run .#deploy-home
        success "Nix Home Manager deployment completed"
        ;;
        
    3)
        info "Testing unified install.sh script..."
        cd /home/$(whoami)/dotfiles
        ./install.sh
        success "Unified installer completed"
        ;;
        
    4)
        info "Testing all deployment methods..."
        
        # Test 1: Chezmoi
        info "Step 1: Testing chezmoi..."
        if ! command -v chezmoi &> /dev/null; then
            sh -c "$(curl -fsLS get.chezmoi.io)"
        fi
        chezmoi init --apply /home/$(whoami)/dotfiles
        success "Chezmoi test passed"
        
        # Test 2: Nix (if available)
        if [ "$SYSTEM_TYPE" = "nixos" ]; then
            info "Step 2: Testing Nix deployment..."
            mkdir -p ~/.config/nix
            echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
            cd ~/.config/nix
            nix run .#deploy-home || warning "Nix deployment failed (non-fatal)"
            success "Nix test completed"
        else
            info "Step 2: Skipping Nix test (not on NixOS)"
        fi
        
        # Test 3: Unified installer
        info "Step 3: Testing unified installer..."
        cd /home/$(whoami)/dotfiles
        ./install.sh
        success "Unified installer test passed"
        
        success "All tests completed successfully!"
        ;;
        
    *)
        error "Invalid choice"
        exit 1
        ;;
esac

echo ""
info "Testing completed! Verify your environment:"
echo "  - Check shell: echo \$SHELL"
echo "  - Check git config: git config --list"
echo "  - Check installed packages: which vim tmux"
echo "  - Check dotfiles: ls -la ~/"
echo ""
success "🎉 Dotfiles testing finished!"