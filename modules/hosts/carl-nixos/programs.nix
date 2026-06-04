{...}: {
  flake.modules.nixos.carl-nixos-programs = {...}: {
    programs.firefox.enable = true;
    programs.steam = {
      enable = true;
      protontricks.enable = true;
    };
    programs.gamescope.enable = true;
  };
}
