{ config, pkgs, lib, ... }:

# WSL-specific Home Manager additions.
# Import alongside home.nix — adds WSL packages and disables WSL-incompatible services.
# Usage in flake.nix: imports = [ ./home.nix ./home-wsl.nix ];
{
  # WSL runs on a modified Linux kernel; genericLinux must stay enabled (set in home.nix)
  # so pacman/apt system paths (/usr/bin etc.) remain accessible.

  # WSL: GPG SSH agent doesn't integrate with Windows SSH agent
  services.gpg-agent = {
    enableSshSupport = lib.mkForce false;
  };

  # WSL: no XDG MIME associations (no GUI app launcher)
  xdg.mimeApps.enable = lib.mkForce false;

  # WSL-specific packages
  home.packages = with pkgs; [
    wslu              # WSL utilities (wslpath, wslview, wslfetch)
    wsl-open          # Open files/URLs in Windows from WSL
  ];

  # WSL: point BROWSER at Windows-side browser via wslview
  home.sessionVariables = {
    BROWSER = lib.mkForce "wslview";
    # Windows username for SSH symlink script
    WIN_USER = "ctr26";
  };
}
