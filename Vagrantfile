# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # NixOS testing environment
  config.vm.define "nixos" do |nixos|
    nixos.vm.box = "nixos/nixos-23.11"
    nixos.vm.hostname = "nixos-dotfiles-test"
    
    # Network configuration
    nixos.vm.network "private_network", ip: "192.168.56.10"
    
    # Provider-specific configuration
    nixos.vm.provider "docker" do |d|
      d.image = "nixos/nix:latest"
      d.name = "nixos-dotfiles-test"
      d.has_ssh = true
    end
    
    # Synced folders
    nixos.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".git/", "node_modules/"]
    
    # Provisioning script
    nixos.vm.provision "shell", inline: <<-SHELL
      echo "🚀 Setting up NixOS test environment..."
      
      # Ensure git is available
      nix-env -iA nixos.git
      
      # Copy dotfiles to user directory
      cp -r /vagrant /home/nixos/dotfiles
      chown -R nixos:users /home/nixos/dotfiles
      
      echo "✅ NixOS environment ready for testing"
    SHELL
    
    # Automatic test provisioner
    nixos.vm.provision "test", type: "shell", run: "never", privileged: false, inline: <<-SHELL
      cd /home/nixos/dotfiles
      echo "🧪 Running automated dotfiles test..."
      
      # Test 1: Chezmoi deployment
      echo "📦 Testing chezmoi deployment..."
      if ! command -v chezmoi &> /dev/null; then
        sh -c "$(curl -fsLS get.chezmoi.io)"
        export PATH="$HOME/.local/bin:$PATH"
      fi
      
      # Initialize with chezmoi (non-interactive)
      export CHEZMOI_CONFIG_DIR="$HOME/.config/chezmoi"
      mkdir -p "$CHEZMOI_CONFIG_DIR"
      cat > "$CHEZMOI_CONFIG_DIR/chezmoi.toml" <<EOF
[data]
    name = "Test User"
    email = "test@example.com"
EOF
      
      chezmoi init --apply /home/nixos/dotfiles
      echo "✅ Chezmoi deployment successful"
      
      # Test 2: Nix Home Manager deployment (if available)
      echo "🏠 Testing Nix Home Manager deployment..."
      mkdir -p ~/.config/nix
      echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
      
      if cd ~/.config/nix && nix run .#deploy-home; then
        echo "✅ Nix Home Manager deployment successful"
      else
        echo "⚠️  Nix Home Manager deployment failed (non-fatal)"
      fi
      
      # Verification
      echo "🔍 Verifying installation..."
      echo "Shell: $SHELL"
      echo "Git config: $(git config user.name) <$(git config user.email)>"
      echo "Installed tools:"
      which vim tmux git || echo "Some tools missing"
      
      echo "🎉 Automated test completed successfully!"
    SHELL
  end
  
  # Ubuntu testing environment (for comparison)
  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "ubuntu/jammy64"
    ubuntu.vm.hostname = "ubuntu-dotfiles-test"
    
    # Network configuration
    ubuntu.vm.network "private_network", ip: "192.168.56.11"
    
    # Provider-specific configuration
    ubuntu.vm.provider "docker" do |d|
      d.image = "ubuntu:22.04"
      d.name = "ubuntu-dotfiles-test"
      d.has_ssh = true
    end
    
    # Synced folders
    ubuntu.vm.synced_folder ".", "/vagrant"
    
    # Provisioning script
    ubuntu.vm.provision "shell", inline: <<-SHELL
      echo "🚀 Setting up Ubuntu test environment..."
      
      # Update package list
      apt-get update
      
      # Install essential packages
      apt-get install -y curl git build-essential
      
      # Copy dotfiles to user directory
      cp -r /vagrant /home/vagrant/dotfiles
      chown -R vagrant:vagrant /home/vagrant/dotfiles
      
      echo "✅ Ubuntu environment ready for testing"
      echo "SSH into VM with: vagrant ssh ubuntu"
      echo "Test dotfiles with: cd ~/dotfiles && ./install.sh"
    SHELL
  end
  
  # macOS testing environment (if running on macOS host)
  config.vm.define "macos", autostart: false do |macos|
    macos.vm.box = "ramsey/macos-catalina"
    macos.vm.hostname = "macos-dotfiles-test"
    
    # Network configuration
    macos.vm.network "private_network", ip: "192.168.56.12"
    
    # Provider-specific configuration
    macos.vm.provider "virtualbox" do |vb|
      vb.name = "macos-dotfiles-test"
      vb.memory = "4096"
      vb.cpus = 2
      vb.gui = true
    end
    
    # Note: macOS VMs require special licensing considerations
    # This is provided as an example - ensure you comply with Apple's licensing terms
  end
end