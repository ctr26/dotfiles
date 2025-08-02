{
  description = "Flexible dotfiles - NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
  let
    # Default username - can be overridden
    defaultUsername = "user";
    
    # Function to create a NixOS configuration for a specific username
    mkNixosConfig = username: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit username; };
      modules = [
        ./dot_config/nix/nixos-module.nix
        ./dot_config/nix/hardware-configuration-stub.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = {
            imports = [ ./dot_config/nix/home.nix ];
            home.username = username;
            home.homeDirectory = "/home/${username}";
          };
        }
      ];
    };
    
    # Function to create a standalone home-manager configuration
    mkHomeConfig = username: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ 
        ./dot_config/nix/home.nix
        {
          home.username = username;
          home.homeDirectory = "/home/${username}";
        }
      ];
    };
    
  in {
    # NixOS system configurations
    nixosConfigurations = {
      # Default configuration
      nixos = mkNixosConfig defaultUsername;
      
      # Specific user configurations (examples)
      nixos-ctr26 = mkNixosConfig "ctr26";
      
      # Users can add more configurations here
    };

    # Standalone home-manager configurations
    homeConfigurations = {
      # Default configuration
      ${defaultUsername} = mkHomeConfig defaultUsername;
      
      # Specific user configurations
      "ctr26" = mkHomeConfig "ctr26";
      
      # Dynamic configuration based on current user
      "current" = mkHomeConfig (builtins.getEnv "USER");
    };

    # Development shell for working with this flake
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = with nixpkgs.legacyPackages.x86_64-linux; [
        nixos-rebuild
        home-manager.packages.x86_64-linux.default
        git
      ];
      shellHook = ''
        echo "🎯 Dotfiles development environment"
        echo "Commands available:"
        echo "  deploy-home    - Deploy home-manager configuration"
        echo "  deploy-system  - Deploy system configuration (requires sudo)"
        echo "  update-flake   - Update flake inputs"
        echo ""
        echo "Current user: $USER"
      '';
    };

    # Apps for easy deployment
    apps.x86_64-linux = {
      # Deploy home-manager only
      deploy-home = {
        type = "app";
        program = toString (nixpkgs.legacyPackages.x86_64-linux.writeShellScript "deploy-home" ''
          set -e
          USERNAME=''${1:-$USER}
          echo "🏠 Deploying home-manager configuration for user: $USERNAME..."
          
          # Determine flake reference (local vs remote)
          if [ -f "./flake.nix" ]; then
            FLAKE_REF="."
            echo "📁 Using local flake"
          else
            FLAKE_REF="github:ctr26/dotfiles"
            echo "🌐 Using remote flake: $FLAKE_REF"
          fi
          
          # Check if configuration exists for this user
          if nix eval --raw "$FLAKE_REF#homeConfigurations.$USERNAME.activationPackage" 2>/dev/null; then
            echo "✅ Found configuration for $USERNAME"
            ${home-manager.packages.x86_64-linux.default}/bin/home-manager switch --flake "$FLAKE_REF#$USERNAME" --no-write-lock-file
          else
            echo "⚠️  No specific configuration for $USERNAME, using current user config..."
            ${home-manager.packages.x86_64-linux.default}/bin/home-manager switch --flake "$FLAKE_REF#current" --no-write-lock-file
          fi
          
          echo "✅ Home configuration deployed!"
        '');
      };

      # Deploy full system (NixOS)
      deploy-system = {
        type = "app";
        program = toString (nixpkgs.legacyPackages.x86_64-linux.writeShellScript "deploy-system" ''
          set -e
          HOSTNAME=''${1:-nixos}
          echo "🖥️  Deploying NixOS configuration for host: $HOSTNAME..."
          
          # Check if we're in the dotfiles directory
          if [ -f "./flake.nix" ]; then
            # Local deployment - copy hardware configuration if it exists
            if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
              echo "📋 Found system hardware configuration"
              sudo nixos-rebuild switch --flake .#$HOSTNAME --impure
            else
              echo "⚠️  No hardware configuration found, using stub configuration"
              sudo nixos-rebuild switch --flake .#$HOSTNAME
            fi
          else
            echo "❌ Please run from the dotfiles directory"
            exit 1
          fi
          
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
          echo "🚀 Flexible dotfiles deployment"
          echo ""
          echo "Current user: $USER"
          echo ""
          echo "Choose deployment option:"
          echo "1) Home Manager only (for current user)"
          echo "2) Home Manager for specific user"
          echo "3) Full NixOS system (requires sudo)"
          echo "4) Update flake inputs"
          echo ""
          read -p "Enter choice (1-4): " choice
          
          # Determine flake reference (local vs remote)
          if [ -f "./flake.nix" ]; then
            FLAKE_REF="."
          else
            FLAKE_REF="github:ctr26/dotfiles"
          fi
          
          case $choice in
            1)
              echo "🏠 Deploying home-manager configuration for $USER..."
              nix run "$FLAKE_REF#deploy-home"
              ;;
            2)
              read -p "Enter username: " username
              echo "🏠 Deploying home-manager configuration for $username..."
              nix run "$FLAKE_REF#deploy-home" -- $username
              ;;
            3)
              read -p "Enter hostname (default: nixos): " hostname
              hostname=''${hostname:-nixos}
              echo "🖥️  Deploying NixOS configuration for $hostname..."
              nix run "$FLAKE_REF#deploy-system" -- $hostname
              ;;
            4)
              nix run "$FLAKE_REF#update"
              ;;
            *)
              echo "❌ Invalid choice"
              exit 1
              ;;
          esac
        '');
      };
    };

    # Helper function to create new user configuration
    lib.mkUserConfig = username: {
      nixos = mkNixosConfig username;
      home = mkHomeConfig username;
    };
  };
}