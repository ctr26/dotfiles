# NixOS module that wraps the configuration with proper hardware handling
{ config, pkgs, lib, ... }:

{
  imports = [
    ./configuration.nix
    # Try to import hardware configuration if it exists
  ] ++ lib.optional (builtins.pathExists /etc/nixos/hardware-configuration.nix)
    /etc/nixos/hardware-configuration.nix;
}