# NixOS module: Claude Code as a persistent tmux-based systemd service.
# Import this from your NixOS configuration.nix:
#   imports = [ ./claude-service.nix ];
#
# Setup:
#   1. Create /etc/claude-env with your API key:
#      ANTHROPIC_API_KEY=sk-ant-...
#   2. chmod 600 /etc/claude-env
#   3. nixos-rebuild switch
#   4. systemctl status claude-code
{ config, pkgs, lib, ... }:

let
  claude-tmux-wrapper = pkgs.writeShellScript "claude-tmux" ''
    export PATH="${lib.makeBinPath [ pkgs.tmux pkgs.nodejs_22 pkgs.coreutils pkgs.bash pkgs.git ]}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
    export HOME="/home/ctr26"

    SESSION="claude"

    # Kill any stale session
    ${pkgs.tmux}/bin/tmux kill-session -t "$SESSION" 2>/dev/null || true

    # Start a new detached tmux session running claude code
    ${pkgs.tmux}/bin/tmux new-session -d -s "$SESSION" -x 200 -y 50 \
      "${pkgs.nodejs_22}/bin/npx -y @anthropic-ai/claude-code"

    # Keep the service alive by polling the tmux session
    while ${pkgs.tmux}/bin/tmux has-session -t "$SESSION" 2>/dev/null; do
      ${pkgs.coreutils}/bin/sleep 5
    done
  '';
in
{
  # Packages available system-wide
  environment.systemPackages = with pkgs; [
    tmux
    nodejs_22
    git
    curl
    zsh
  ];

  # User account
  users.users.ctr26 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  # The systemd service
  systemd.services.claude-code = {
    description = "Claude Code in a persistent tmux session";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "ctr26";
      Group = "users";

      ExecStart = claude-tmux-wrapper;

      # Auto-restart on failure
      Restart = "on-failure";
      RestartSec = 10;

      # Env file for API keys — systemd skips it if missing
      EnvironmentFile = "-/etc/claude-env";

      # Hardening
      ProtectSystem = "strict";
      ReadWritePaths = [
        "/home/ctr26"
        "/tmp"
        "/run"
      ];
      PrivateTmp = false;  # tmux needs shared /tmp for its socket
      NoNewPrivileges = true;
    };
  };

  # Firewall: allow SSH
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Enable zsh
  programs.zsh.enable = true;
}
