# NixOS module that wraps the configuration with proper hardware handling
{ config, pkgs, lib, username ? "user", ... }:

{
  imports = [
    ./configuration.nix
    # Try to import hardware configuration if it exists
  ] ++ lib.optional (builtins.pathExists /etc/nixos/hardware-configuration.nix)
    /etc/nixos/hardware-configuration.nix;

  # Define the user account with the provided username
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };
}