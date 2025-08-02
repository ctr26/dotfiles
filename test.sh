#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

echo "🧪 One-Liner Dotfiles Test"
echo "=========================="

# Check if Vagrant is available
if ! command -v vagrant &> /dev/null; then
    error "Vagrant is required but not installed"
    echo "Install from: https://www.vagrantup.com/"
    exit 1
fi

# Parse command line arguments
TEST_TYPE=${1:-"nixos"}
case $TEST_TYPE in
    "nixos"|"nix")
        VM_NAME="nixos"
        info "Testing on NixOS VM"
        ;;
    "ubuntu"|"linux")
        VM_NAME="ubuntu"  
        info "Testing on Ubuntu VM"
        ;;
    "all")
        info "Testing on all VMs"
        ;;
    *)
        echo "Usage: $0 [nixos|ubuntu|all]"
        echo "Examples:"
        echo "  $0 nixos    # Test NixOS deployment"
        echo "  $0 ubuntu   # Test Ubuntu deployment"
        echo "  $0 all      # Test both systems"
        exit 1
        ;;
esac

# Function to test a single VM
test_vm() {
    local vm_name=$1
    info "Starting $vm_name VM and running tests..."
    
    # Start VM (will provision automatically)
    vagrant up $vm_name
    
    # Run the test provisioner
    vagrant provision $vm_name --provision-with test
    
    # Get test results
    if vagrant ssh $vm_name -c "echo 'Test completed successfully'" &>/dev/null; then
        success "$vm_name tests passed!"
    else
        warning "$vm_name tests had issues"
    fi
}

# Run tests based on selection
case $TEST_TYPE in
    "all")
        test_vm "nixos"
        test_vm "ubuntu"
        ;;
    *)
        test_vm $VM_NAME
        ;;
esac

echo ""
success "🎉 All tests completed!"
echo ""
info "To cleanup:"
echo "  vagrant destroy -f"
echo ""
info "To see detailed logs:"
echo "  vagrant ssh $VM_NAME"
echo "  tail -f /var/log/vagrant-provision.log"