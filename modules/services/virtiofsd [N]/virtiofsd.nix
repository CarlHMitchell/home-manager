{
  flake.modules.nixos.virtiofsd = {
    config,
    pkgs,
    ...
  }: {
    # Use --user for this, e.g. `systemctl --user status virtiofsd-vm`
    systemd.user.services.virtiofsd-vm = {
      description = "virtiofsd for Windows VM";
      wantedBy = ["default.target"];
      serviceConfig = {
        ExecStartPre = "-${pkgs.coreutils}/bin/rm %t/virtiofs.sock";
        ExecStart = "${pkgs.virtiofsd}/bin/virtiofsd --socket-path=%t/virtiofs.sock --shared-dir=${config.users.users.carl.home}/Public";
        Restart = "always";
      };
    };
  };
}
