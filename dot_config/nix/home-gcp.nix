{ config, pkgs, lib, ... }:

# GCP VM-specific Home Manager additions.
# Import alongside home.nix — adds GCP/cloud tools, removes desktop-only packages.
# Usage in flake.nix: imports = [ ./home.nix ./home-gcp.nix ];
{
  # GCP: no display server, no GUI tools
  services.gpg-agent = {
    enableSshSupport = lib.mkForce false;
  };
  xdg.mimeApps.enable = lib.mkForce false;

  # GCP-specific packages
  home.packages = with pkgs; [
    google-cloud-sdk  # gcloud CLI
    kubectl           # Kubernetes CLI
    terraform         # Infrastructure as code
    k9s               # Kubernetes TUI
    jq                # JSON processor
    yq-go             # YAML processor
    uv                # Fast Python package manager
    ruff              # Python linter/formatter
    mypy              # Python type checker
  ];

  # GCP environment
  home.sessionVariables = {
    BROWSER = lib.mkForce "";
    CLOUDSDK_PYTHON = "${pkgs.python3}/bin/python3";
  };
}
