# Dotfiles Testing Makefile

.PHONY: test test-nixos test-ubuntu test-all clean help

# Default target
help:
	@echo "🧪 Dotfiles Testing Commands"
	@echo "============================"
	@echo ""
	@echo "Quick Tests:"
	@echo "  make test          # Test NixOS deployment (default)"
	@echo "  make test-nixos    # Test NixOS deployment"
	@echo "  make test-ubuntu   # Test Ubuntu deployment"
	@echo "  make test-all      # Test both systems"
	@echo ""
	@echo "Management:"
	@echo "  make clean         # Destroy all VMs"
	@echo "  make status        # Show VM status"
	@echo ""
	@echo "Manual:"
	@echo "  vagrant up nixos   # Start NixOS VM"
	@echo "  vagrant ssh nixos  # SSH into VM"

# Test NixOS deployment (default)
test: test-nixos

# Test NixOS deployment
test-nixos:
	@echo "🐧 Testing NixOS deployment..."
	./test.sh nixos

# Test Ubuntu deployment  
test-ubuntu:
	@echo "🟠 Testing Ubuntu deployment..."
	./test.sh ubuntu

# Test all systems
test-all:
	@echo "🌍 Testing all systems..."
	./test.sh all

# Clean up all VMs
clean:
	@echo "🧹 Cleaning up test VMs..."
	vagrant destroy -f || true
	@echo "✅ All VMs destroyed"

# Show VM status
status:
	@echo "📊 VM Status:"
	vagrant status

# Quick deployment test (super fast)
quick:
	@echo "⚡ Quick test (chezmoi only)..."
	vagrant up nixos --no-provision
	vagrant ssh nixos -c "cd /home/nixos/dotfiles && sh -c \"\$$(curl -fsLS get.chezmoi.io)\" && export PATH=\"\$$HOME/.local/bin:\$$PATH\" && echo -e '[data]\\nname=\"Test User\"\\nemail=\"test@example.com\"' > ~/.config/chezmoi/chezmoi.toml && chezmoi init --apply /home/nixos/dotfiles"
	@echo "✅ Quick test completed"