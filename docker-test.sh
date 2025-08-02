#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

echo "🐳 Docker-based Dotfiles Test"
echo "============================="

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    error "Docker is required but not installed"
    exit 1
fi

# Test type selection
TEST_TYPE=${1:-"nixos"}
case $TEST_TYPE in
    "nixos"|"nix")
        DOCKER_IMAGE="nixos/nix:latest"
        info "Testing on NixOS container"
        ;;
    "ubuntu"|"linux")
        DOCKER_IMAGE="ubuntu:22.04"
        info "Testing on Ubuntu container"
        ;;
    *)
        echo "Usage: $0 [nixos|ubuntu]"
        exit 1
        ;;
esac

# Container name
CONTAINER_NAME="dotfiles-test-$(date +%s)"

info "Starting $TEST_TYPE container..."

# Run container with dotfiles mounted
docker run -it --rm \
    --name "$CONTAINER_NAME" \
    -v "$(pwd):/dotfiles:ro" \
    -w /dotfiles \
    "$DOCKER_IMAGE" \
    bash -c "
        set -e
        echo '🧪 Testing dotfiles deployment in container...'
        
        # Install basic tools
        if command -v apt-get &> /dev/null; then
            apt-get update
            apt-get install -y curl git
        elif command -v nix-env &> /dev/null; then
            nix-env -iA nixos.curl nixos.git
        fi
        
        # Test chezmoi installation
        echo '📦 Testing chezmoi installation...'
        sh -c \"\$(curl -fsLS get.chezmoi.io)\"
        export PATH=\"\$HOME/.local/bin:\$PATH\"
        
        # Create test config
        mkdir -p \$HOME/.config/chezmoi
        cat > \$HOME/.config/chezmoi/chezmoi.toml <<EOF
[data]
    name = \"Test User\"
    email = \"test@example.com\"
EOF
        
        # Initialize dotfiles
        echo '🏠 Initializing dotfiles...'
        chezmoi init --apply /dotfiles
        
        # Verify installation
        echo '🔍 Verifying installation...'
        echo \"Shell: \$SHELL\"
        if [ -f \$HOME/.gitconfig ]; then
            echo \"Git config: \$(git config user.name) <\$(git config user.email)>\"
        else
            echo \"Git config: Not configured\"
        fi
        
        echo \"Installed tools:\"
        which vim 2>/dev/null && echo \"- vim: ✅\" || echo \"- vim: ❌\"
        which tmux 2>/dev/null && echo \"- tmux: ✅\" || echo \"- tmux: ❌\"
        which git 2>/dev/null && echo \"- git: ✅\" || echo \"- git: ❌\"
        
        echo '🎉 Container test completed successfully!'
    "

success "Docker test completed!"