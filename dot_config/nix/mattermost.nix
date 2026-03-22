# Mattermost NixOS configuration for GCP
# Runs Mattermost via Docker Compose on a persistent data disk
{ config, pkgs, lib, ... }:

{
  imports = [
    ./gcp-base.nix
  ];

  # ── Hostname ───────────────────────────────────────────────────────
  networking.hostName = "mattermost";

  # ── Firewall — expose HTTP(S) and Mattermost default port ─────────
  networking.firewall.allowedTCPPorts = [ 80 443 8065 ];

  # ── Persistent data disk ───────────────────────────────────────────
  # GCP attaches the disk as /dev/disk/by-id/google-mattermost-data.
  # Format on first boot, then mount to /var/mattermost.
  fileSystems."/var/mattermost" = {
    device = "/dev/disk/by-id/google-mattermost-data";
    fsType = "ext4";
    autoFormat = true;
    options = [ "discard" "defaults" ];
  };

  # ── Data directories ──────────────────────────────────────────────
  systemd.tmpfiles.rules = [
    "d /var/mattermost/db        0750 999  999  -"
    "d /var/mattermost/app/data  0750 2000 2000 -"
    "d /var/mattermost/app/logs  0750 2000 2000 -"
    "d /var/mattermost/app/config        0750 2000 2000 -"
    "d /var/mattermost/app/plugins       0750 2000 2000 -"
    "d /var/mattermost/app/client-plugins 0750 2000 2000 -"
  ];

  # ── Docker Compose unit ────────────────────────────────────────────
  # The compose file is managed externally (Terraform template or
  # manual placement at /opt/mattermost/docker-compose.yml).
  systemd.services.mattermost-compose = {
    description = "Mattermost Docker Compose stack";
    after = [ "docker.service" "network-online.target" "var-mattermost.mount" ];
    wants = [ "docker.service" "network-online.target" "var-mattermost.mount" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/opt/mattermost";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
    };
  };

  # ── Extra packages ────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    certbot   # TLS certificate management
  ];
}
