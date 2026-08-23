{...}: {
  flake.modules.nixos.gaming = {...}: {
    programs = {
      steam = {
        enable = true;
        protontricks.enable = true;
      };
      gamescope = {
        enable = true;
        capSysNice = false;
      };
      gamemode.enable = true;
    };
  };

  flake.modules.homeManager.gaming = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      #packages
      discord
      steam
      protontricks
    ];
  };
}
