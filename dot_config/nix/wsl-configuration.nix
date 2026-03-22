# NixOS-WSL configuration
# WSL-specific settings - no X11, no bootloader, no desktop environment
{ config, pkgs, lib, username ? "user", ... }:

{
  # ============================================================================
  # WSL SETTINGS
  # ============================================================================

  wsl = {
    enable = true;
    defaultUser = username;

    # Windows interop - access Windows executables from WSL
    interop = {
      register = true;
      includePath = true;
    };

    # Fix SSH key permissions on Windows-mounted filesystems
    wslConf.automount.options = "metadata,umask=22,fmask=11";

    # Start a login shell by default
    startMenuLaunchers = true;
  };

  # ============================================================================
  # SYSTEM CONFIGURATION
  # ============================================================================

  # Hostname
  networking.hostName = "wsl";

  # Locale
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Define the user account
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # ============================================================================
  # DOCKER
  # ============================================================================

  virtualisation.docker.enable = true;

  # ============================================================================
  # PACKAGES
  # ============================================================================

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Essential system utilities
    vim
    neovim
    git
    curl
    wget
    htop
    btop
    tree
    unzip
    file

    # Development tools
    gcc
    gnumake
    pkg-config

    # Shell utilities
    zsh
    oh-my-zsh
    tmux
    ranger

    # Fonts
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.jetbrains-mono
  ];

  # Font configuration
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.jetbrains-mono
  ];

  # ============================================================================
  # SERVICES
  # ============================================================================

  services.openssh.enable = true;

  # ============================================================================
  # NIX SETTINGS
  # ============================================================================

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # ============================================================================
  # NOTE: The following are intentionally EXCLUDED for WSL:
  # - boot.loader.* (WSL manages its own boot)
  # - services.xserver.* (no X11/i3/polybar/lightdm needed)
  # - services.pipewire/pulseaudio (use Windows audio)
  # - services.printing (use Windows printers)
  # - networking.networkmanager (WSL manages networking)
  # ============================================================================

  system.stateVersion = "24.05";
}
