# GCP base NixOS configuration
# Common settings for all GCP VM instances provisioned via nixos-infect
{ config, pkgs, lib, ... }:

{
  # ── System basics ──────────────────────────────────────────────────
  system.stateVersion = "24.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader — GRUB for GCP Compute Engine VMs
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # ── Networking ─────────────────────────────────────────────────────
  networking.networkmanager.enable = lib.mkDefault false;
  networking.useDHCP = lib.mkDefault true;

  # ── Locale / timezone ─────────────────────────────────────────────
  time.timeZone = lib.mkDefault "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # ── OS Login integration ───────────────────────────────────────────
  # google-oslogin PAM + NSS module lets `gcloud compute ssh` work.
  security.pam.services.sshd.googleOsLogin.enable = true;
  security.googleOsLogin.enable = true;

  # ── SSH ────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  # ── Docker ─────────────────────────────────────────────────────────
  virtualisation.docker.enable = true;
  systemd.services.docker.wantedBy = [ "multi-user.target" ];

  # ── Nix garbage collection ────────────────────────────────────────
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;

  # ── Monitoring / logging ───────────────────────────────────────────
  # Google Cloud Ops Agent is not packaged in nixpkgs; use the
  # lightweight alternative: node_exporter + journald → Cloud Logging.
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "systemd" "processes" ];
    port = 9100;
  };

  # Forward journal to console so serial-port logs reach Cloud Logging
  services.journald.extraConfig = ''
    ForwardToConsole=yes
    MaxLevelConsole=info
  '';

  # ── Firewall ───────────────────────────────────────────────────────
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # ── Packages ───────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Essentials
    git
    vim
    curl
    wget
    htop
    tmux
    jq
    # Containers
    docker-compose
    # GCP CLI (unfree)
    google-cloud-sdk
  ];
}
