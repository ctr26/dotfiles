{ config, pkgs, lib, ... }:

{
  # Note: unfree packages are handled by the system configuration when using useGlobalPkgs
  # Home Manager needs a bit of information about you and the paths it should
  # manage. These are set via flake parameters.
  # home.username and home.homeDirectory are provided by the flake

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Enable nix-index for command-not-found functionality
  programs.nix-index.enable = true;

  # ============================================================================
  # PACKAGES ONLY - Let chezmoi manage all dotfiles and configurations
  # ============================================================================

  # Shell programs (install only, no config)
  programs.zsh.enable = true;         # Install ZSH
  programs.bash.enable = true;        # Install Bash
  
  # Development tools (install only, no config)
  programs.git.enable = true;         # Install Git (chezmoi manages ~/.gitconfig)
  programs.vim.enable = true;         # Install Vim (chezmoi manages ~/.vimrc)
  programs.neovim = {                 # Install Neovim
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;                # Enable Node.js support for plugins
    withPython3 = true;               # Enable Python 3 support for plugins
  };
  
  # Terminal multiplexer (install only, no config)
  programs.tmux.enable = true;        # Install tmux (chezmoi manages ~/.tmux.conf)
  
  # Terminal emulator (install only, no config)  
  programs.kitty.enable = true;       # Install Kitty (chezmoi manages ~/.config/kitty/)

  # ============================================================================
  # PACKAGE INSTALLATION - Home Manager handles packages, chezmoi handles configs
  # ============================================================================
  
  home.packages = with pkgs; [
    # System utilities
    autojump              # Directory jumping
    fzf                   # Fuzzy finder
    ripgrep               # Fast grep
    fd                    # Fast find
    tree                  # Directory tree
    htop                  # Process monitor
    curl                  # HTTP client
    wget                  # File downloader
    unzip                 # Archive extraction
    chezmoi               # Dotfile manager
    rsync                 # File sync
    socat                 # Socket relay
    inetutils             # ping, ftp, telnet, etc.
    nano                  # Simple editor
    bc                    # Calculator
    dos2unix              # Line ending converter
    ncdu                  # Disk usage analyser
    lolcat                # Rainbow output
    figlet                # ASCII art text
    neofetch              # System info

    # File deduplication
    fdupes                # Find duplicate files
    jdupes                # Fast duplicate finder
    rdfind                # Redundant file finder

    # Archive / transfer
    aria2                 # Multi-protocol downloader

    # Search / filesystem
    dnsutils              # dig, nslookup (from bind)

    # Development tools
    git                   # Version control
    gh                    # GitHub CLI
    gnumake               # Build automation
    docker                # Container runtime
    docker-compose        # Container orchestration
    ruff                  # Python linter + formatter
    mypy                  # Python type checker
    ccache                # Compiler cache
    doxygen               # Documentation generator
    maturin               # Build Rust extensions for Python
    pandoc                # Document converter
    xmlto                 # XML to other formats
    fnm                   # Fast Node version manager
    keychain              # SSH/GPG key manager

    # Spell checking
    aspell                # Spell checker
    hunspell              # Spell checker (LibreOffice-compatible)
    nuspell               # Modern spell checker
    hspell                # Hebrew spell checker

    # Infrastructure
    terraform             # Infrastructure as code
    google-cloud-sdk      # GCP CLI
    kubernetes-helm       # Helm package manager for k8s
    kubectl               # Kubernetes CLI
    vagrant               # VM manager
    sshfs                 # Mount remote filesystems over SSH

    # Languages and runtimes
    nodejs                # JavaScript runtime
    python3               # Python interpreter
    go                    # Go compiler
    rust-analyzer         # Rust language server
    uv                    # Fast Python package manager

    # Media
    ffmpeg                # Audio/video processing

    # Terminal utilities
    tmux                  # Terminal multiplexer
    ranger                # File manager
    bat                   # Syntax-highlighted cat
    btop                  # Modern process monitor
    nvtop                 # GPU process monitor
    eza                   # Modern ls replacement
    jq                    # JSON query tool
    yq-go                 # YAML query tool

    # Editors and IDEs
    # vscode              # (unfree - uncomment if needed)
    # obsidian            # (unfree - uncomment if needed)

    # Password / secrets
    _1password-cli        # 1Password CLI

    # Email
    himalaya              # TUI email client

    # Fonts
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.jetbrains-mono
  ];

  # ============================================================================
  # SYSTEM SERVICES - Things that make sense for Home Manager to handle
  # ============================================================================

  # Font configuration
  fonts.fontconfig.enable = true;

  # XDG configuration
  xdg.enable = true;
  xdg.mimeApps.enable = true;

  # Service management
  services = {
    # Enable GPG agent for SSH
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };
  };

  # Session variables (system-level environment)
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/docker.sock";
  };

  # ============================================================================
  # NO FILE MANAGEMENT - Let chezmoi handle ALL dotfiles and configurations
  # ============================================================================
  
  # NOTE: We deliberately do NOT use:
  # - programs.git.userName/userEmail (chezmoi manages ~/.gitconfig)
  # - programs.zsh.initExtra (chezmoi manages ~/.zshrc)
  # - programs.tmux.extraConfig (chezmoi manages ~/.tmux.conf)
  # - programs.vim.plugins (chezmoi manages ~/.vimrc)
  # - programs.kitty.settings (chezmoi manages ~/.config/kitty/kitty.conf)
  # - home.file.* (chezmoi manages all home directory files)
  
  # This creates a clean separation:
  # - Home Manager: Package installation + system services
  # - Chezmoi: All configuration files and dotfiles

  # ============================================================================
  # CHEZMOI INTEGRATION - Auto-deploy dotfiles on system activation
  # ============================================================================
  
  # Activation script to automatically apply chezmoi dotfiles
  home.activation.chezmoi = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "🎯 Setting up chezmoi for user: $USER..."
    
    # Set HOME explicitly to avoid any confusion
    export HOME="${config.home.homeDirectory}"
    
    # Skip scripts during chezmoi apply to avoid circular dependencies
    export CHEZMOI_SKIP_SCRIPTS=1
    
    # Check if chezmoi is initialized
    if [ ! -d "$HOME/.local/share/chezmoi" ]; then
      echo "📦 Initializing chezmoi for the first time..."
      # Initialize without applying to avoid the username check issue
      ${pkgs.chezmoi}/bin/chezmoi init https://github.com/ctr26/dotfiles.git --apply=false
      
      # Now apply with proper environment, excluding scripts
      echo "🔄 Applying dotfiles..."
      ${pkgs.chezmoi}/bin/chezmoi apply --exclude=scripts --force
    else
      echo "🔄 Updating dotfiles..."
      # Update without the problematic script execution
      cd "$HOME/.local/share/chezmoi" && ${pkgs.git}/bin/git pull
      ${pkgs.chezmoi}/bin/chezmoi apply --exclude=scripts --force
    fi
    
    echo "✅ Chezmoi dotfiles applied successfully!"
  '';
}