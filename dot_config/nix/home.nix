{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ctr26";
  home.homeDirectory = "/home/ctr26";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Enable nix-index for command-not-found functionality
  programs.nix-index.enable = true;

  # Shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "docker"
        "tmux"
        "autojump"
        "colorize"
        "cp"
      ];
      theme = "robbyrussell";
    };

    initExtra = ''
      # Pure prompt setup
      fpath+=($HOME/.zsh/pure)
      autoload -U promptinit; promptinit
      prompt pure

      # tmux configuration
      ZSH_TMUX_AUTOSTART=true
      ZSH_TMUX_AUTOCONNECT=false
      ZSH_TMUX_AUTOSTART_ONCE=false
      ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh

      if [[ ! -d $ZSH_CACHE_DIR ]]; then
        mkdir $ZSH_CACHE_DIR
      fi

      # Antigen setup
      source $HOME/antigen/antigen.zsh
      antigen init $HOME/.antigenrc
    '';
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      # User specific environment
      if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
      then
          PATH="$HOME/.local/bin:$HOME/bin:$PATH"
      fi
      export PATH

      # Autojump
      [[ -s .autojump/bin/autojump.sh ]] && source .autojump/bin/autojump.sh
      export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
    '';
  };

  # Git configuration
  programs.git = {
    enable = true;
    # userName and userEmail should be set via template variables
    # or overridden in the NixOS configuration
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  # Vim configuration
  programs.vim = {
    enable = true;
    settings = {
      number = true;
    };
    plugins = with pkgs.vimPlugins; [
      vim-fugitive
      vim-surround
      nerdtree
      vim-repeat
      vim-commentary
      vim-sensible
      vim-markdown
      fzf-vim
      onedark-vim
      nvim-web-devicons
      nvim-tree-lua
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-vsnip
      vim-vsnip
      vimwiki
    ];
  };

  # Neovim with AstroNvim-like setup
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # tmux configuration
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    escapeTime = 10;
    extraConfig = ''
      set-option -g detach-on-destroy off
      
      # Catppuccin theme
      set -g @catppuccin_flavour 'mocha'
      set -g @catppuccin_user "on"
      set -g @catppuccin_host "on"
    '';
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      open
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
        '';
      }
    ];
  };

  # Kitty terminal
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.95";
      confirm_os_window_close = 0;
      shell = "${pkgs.tmux}/bin/tmux";
    };
    theme = "Catppuccin-Mocha";
  };

  # Development tools
  home.packages = with pkgs; [
    # System utilities
    autojump
    fzf
    ripgrep
    fd
    tree
    htop
    curl
    wget
    unzip
    
    # Development tools
    git
    gh
    docker
    docker-compose
    
    # Languages and runtimes
    nodejs
    python3
    go
    rust-analyzer
    
    # Editors and IDEs
    vscode
    
    # Terminal multiplexer and utilities
    tmux
    
    # Window management (if using X11/i3)
    i3
    polybar
    rofi
    
    # Fonts
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "JetBrainsMono" ]; })
  ];

  # Font configuration
  fonts.fontconfig.enable = true;

  # XDG configuration
  xdg.enable = true;
  
  # File associations and desktop entries
  xdg.mimeApps.enable = true;

  # Service management
  services = {
    # Enable GPG agent for SSH
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };
  };

  # Session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/docker.sock";
  };

  # File management for dotfiles that need manual symlinking
  # Note: Most files are managed by chezmoi, these are additional symlinks
  home.file = {
    # These would typically be managed by chezmoi
    # Uncomment if you want home-manager to override chezmoi management
    # ".antigenrc".source = ../../dot_antigenrc;
    # ".condarc".source = ../../dot_condarc;
    
    # i3 configuration (if not using chezmoi for this)
    # ".config/i3/config".source = ../i3/config;
    
    # Additional files that chezmoi doesn't handle well
  };

  # External dependencies that need to be cloned
  home.activation = {
    setupExternalDeps = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Setup oh-my-zsh (handled by programs.zsh.oh-my-zsh.enable)
      
      # Setup Pure prompt
      if [ ! -d "$HOME/.zsh/pure" ]; then
        ${pkgs.git}/bin/git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
      fi
      
      # Setup Antigen
      if [ ! -d "$HOME/antigen" ]; then
        ${pkgs.git}/bin/git clone https://github.com/zsh-users/antigen.git "$HOME/antigen"
      fi
      
      # Setup autojump (if not using package)
      if [ ! -d "$HOME/.local/share/autojump" ]; then
        ${pkgs.git}/bin/git clone https://github.com/wting/autojump.git "$HOME/.local/share/autojump"
        cd "$HOME/.local/share/autojump"
        ./install.py
      fi
    '';
  };
}