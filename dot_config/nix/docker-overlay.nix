# Docker overlay - just adds Docker to existing NixOS configuration
# This can be imported into any existing NixOS system
{ config, pkgs, lib, username ? "user", ... }:

{
  # Enable Docker
  virtualisation.docker.enable = true;
  
  # Add user to docker group
  users.users.${username}.extraGroups = [ "docker" ];
  
  # Install docker-compose system-wide
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
  
  # Optional: Enable docker at boot
  systemd.services.docker.wantedBy = [ "multi-user.target" ];
}