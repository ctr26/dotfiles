{
  description = "ctr26's dotfiles - NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    # NixOS system configurations
    nixosConfigurations = {
      # Default system configuration - adjust hostname as needed
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./dot_config/nix/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ctr26 = import ./dot_config/nix/home.nix;
          }
        ];
      };
    };

    # Standalone home-manager configurations
    homeConfigurations = {
      "ctr26" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./dot_config/nix/home.nix ];
      };
    };

    # Development shell for working with this flake
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
        nixos-rebuild
        home-manager
        git
      ];
      shellHook = ''
        echo "🎯 Dotfiles development environment"
        echo "Commands available:"
        echo "  deploy-home    - Deploy home-manager configuration"
        echo "  deploy-system  - Deploy system configuration (requires sudo)"
        echo "  update-flake   - Update flake inputs"
      '';
    };

    # Apps for easy deployment
    apps.x86_64-linux = {
      # Deploy home-manager only
      deploy-home = {
        type = "app";
        program = toString (nixpkgs.legacyPackages.x86_64-linux.writeShellScript "deploy-home" ''
          set -e
          echo "🏠 Deploying home-manager configuration..."
          ${home-manager.packages.x86_64-linux.default}/bin/home-manager switch --flake .#ctr26
          echo "✅ Home configuration deployed!"
        '');
      };

      # Deploy full system (NixOS)
      deploy-system = {
        type = "app";
        program = toString (nixpkgs.legacyPackages.x86_64-linux.writeShellScript "deploy-system" ''
          set -e
          echo "🖥️  Deploying NixOS configuration..."
          sudo nixos-rebuild switch --flake .#nixos
          echo "✅ System configuration deployed!"
        '');
      };

      # Update flake inputs
      update = {
        type = "app";
        program = toString (nixpkgs.legacyPackages.x86_64-linux.writeShellScript "update-flake" ''
          set -e
          echo "🔄 Updating flake inputs..."
          nix flake update
          echo "✅ Flake inputs updated!"
        '');
      };

      # Default app - interactive deployment
      default = {
        type = "app";
        program = toString (nixpkgs.legacyPackages.x86_64-linux.writeShellScript "deploy-interactive" ''
          set -e
          echo "🚀 ctr26's dotfiles deployment"
          echo ""
          echo "Choose deployment option:"
          echo "1) Home Manager only (user configurations)"
          echo "2) Full NixOS system (requires sudo)"
          echo "3) Update flake inputs"
          echo ""
          read -p "Enter choice (1-3): " choice
          
          case $choice in
            1)
              echo "🏠 Deploying home-manager configuration..."
              ${home-manager.packages.x86_64-linux.default}/bin/home-manager switch --flake .#ctr26
              echo "✅ Home configuration deployed!"
              ;;
            2)
              echo "🖥️  Deploying NixOS configuration..."
              sudo nixos-rebuild switch --flake .#nixos
              echo "✅ System configuration deployed!"
              ;;
            3)
              echo "🔄 Updating flake inputs..."
              nix flake update
              echo "✅ Flake inputs updated!"
              ;;
            *)
              echo "❌ Invalid choice"
              exit 1
              ;;
          esac
        '');
      };
    };

    # Packages for one-command install scripts
    packages.x86_64-linux = {
      install-script = nixpkgs.legacyPackages.x86_64-linux.writeShellScriptBin "install-dotfiles" ''
        set -e
        
        echo "🎯 Installing ctr26's dotfiles..."
        
        # Check if Nix is installed
        if ! command -v nix &> /dev/null; then
          echo "📦 Installing Nix..."
          sh <(curl -L https://nixos.org/nix/install) --daemon
          . /etc/profile
        fi
        
        # Enable flakes if not already enabled
        if [ ! -f ~/.config/nix/nix.conf ] || ! grep -q "experimental-features.*flakes" ~/.config/nix/nix.conf; then
          echo "🔧 Enabling Nix flakes..."
          mkdir -p ~/.config/nix
          echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
        fi
        
        # Clone dotfiles if not already present
        if [ ! -d "$HOME/dotfiles" ]; then
          echo "📥 Cloning dotfiles repository..."
          git clone https://github.com/ctr26/dotfiles.git "$HOME/dotfiles"
        fi
        
        cd "$HOME/dotfiles"
        
        # Check if running on NixOS
        if [ -f /etc/nixos/configuration.nix ]; then
          echo "🖥️  NixOS detected - deploying full system configuration"
          nix run .#deploy-system
        else
          echo "🏠 Non-NixOS system - deploying home-manager only"
          nix run .#deploy-home
        fi
        
        echo "🎉 Dotfiles installation complete!"
      '';
    };
  };
}