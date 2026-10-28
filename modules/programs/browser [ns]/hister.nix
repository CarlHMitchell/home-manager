{
  # One feature, one aspect per module class:
  #   NixOS host:      nixos.hister (service + package)
  #   standalone HM:   homeManager.hister (package + systemd user unit)

  flake.modules.nixos.hister = {
    services.hister = {
      enable = true;
      port = 4433;
    };
  };

  flake.modules.homeManager.hister = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.hister];

    systemd.user.services.hister = {
      Unit = {
        Description = "Hister web history service";
        After = ["network.target"];
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.hister} listen";
        Environment = [
          "HISTER_PORT=4433"
          "HISTER_DATA_DIR=%h/.local/share/hister"
        ];
        Restart = "on-failure";
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
