{...}: {
  flake.modules.nixos.carl-nixos-programs = {...}: {
    programs = {
      firefox.enable = true;
      steam = {
        enable = true;
        protontricks.enable = true;
      };
      gamescope = {
        enable = true;
        capSysNice = false;
      };
      gamemode.enable = true;

      kdeconnect.enable = true;

      zoom-us.enable = true;

      java = {
        enable = true;
        package = jdk;
      };
    };
  };
}
