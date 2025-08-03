# Minimal system services configuration
# Only the essential services that require sudo/system-level access
{ config, pkgs, lib, ... }:

{
  imports = [
    # Import hardware configuration stub for bootloader/filesystem
    ./hardware-configuration-stub.nix
  ];

  # Basic system configuration
  system.stateVersion = "24.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Bootloader (minimal, may not work in all environments)
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  
  # Basic networking
  networking.hostName = lib.mkDefault "nixos";
  networking.networkmanager.enable = lib.mkDefault true;
  
  # Enable Docker (requires system-level configuration)
  virtualisation.docker.enable = true;
  
  # Add current user to docker group (will be set by flake)
  users.extraGroups.docker.members = [ ];
  
  # Enable SSH server (optional, commonly needed)
  services.openssh.enable = lib.mkDefault true;
  
  # Allow unfree packages (for things like Docker Desktop, etc.)
  nixpkgs.config.allowUnfree = true;
  
  # Essential system packages that need to be system-wide
  environment.systemPackages = with pkgs; [
    docker-compose
    git
    vim
    curl
    wget
  ];
}