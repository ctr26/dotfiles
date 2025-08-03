# Dotfiles Testing Makefile

.PHONY: test test-nixos test-ubuntu test-all clean help deploy deploy-backup

# Default target
help:
	@echo "🏠 Dotfiles Commands"
	@echo "===================="
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy        # Deploy to current NixOS system"
	@echo "  make deploy-backup # Deploy with backup of existing files"
	@echo ""
	@echo "Testing:"
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

# Deploy to current NixOS system
deploy:
	@echo "🚀 Deploying dotfiles to NixOS..."
	@if command -v nix >/dev/null 2>&1; then \
		NIX_CONFIG="experimental-features = nix-command flakes" nix run --refresh --no-write-lock-file github:ctr26/dotfiles#deploy-home; \
	else \
		echo "❌ Nix not found. This command only works on NixOS or systems with Nix installed."; \
		echo "💡 To install on non-NixOS systems, use:"; \
		echo "   curl -sSL https://raw.githubusercontent.com/ctr26/dotfiles/main/install.sh | bash"; \
		exit 1; \
	fi

# Deploy with backup of existing files
deploy-backup:
	@echo "🚀 Deploying dotfiles with backup..."
	@if command -v nix >/dev/null 2>&1; then \
		NIX_CONFIG="experimental-features = nix-command flakes" nix run --refresh --no-write-lock-file github:ctr26/dotfiles#deploy-home -- --backup-extension backup; \
	else \
		echo "❌ Nix not found. This command only works on NixOS or systems with Nix installed."; \
		echo "💡 To install on non-NixOS systems, use:"; \
		echo "   curl -sSL https://raw.githubusercontent.com/ctr26/dotfiles/main/install.sh | bash"; \
		exit 1; \
	fi

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