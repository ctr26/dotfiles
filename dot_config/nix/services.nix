# Minimal system services configuration
# Only the essential services that require sudo/system-level access
{ config, pkgs, lib, ... }:

{
  # Enable Docker (requires system-level configuration)
  virtualisation.docker.enable = true;
  
  # Add current user to docker group (will be set by flake)
  users.extraGroups.docker.members = [ ];
  
  # Enable SSH server (optional, commonly needed)
  services.openssh.enable = lib.mkDefault true;
  
  # Enable NetworkManager (if not already enabled)
  networking.networkmanager.enable = lib.mkDefault true;
  
  # Allow unfree packages (for things like Docker Desktop, etc.)
  nixpkgs.config.allowUnfree = true;
  
  # Essential system packages that need to be system-wide
  environment.systemPackages = with pkgs; [
    docker-compose
    git
    vim
  ];
}