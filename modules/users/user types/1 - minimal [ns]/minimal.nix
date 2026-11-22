{inputs, ...}: {
  # default settings needed for all homeManagerConfigurations
  flake.modules.homeManager.user-minimal = {
    config,
    pkgs,
    pkgs-unstable,
    pkgs-oldstable,
    lib,
    ...
  }: {
    home = {
      homeDirectory = "/home/${config.home.username}";
    };

    xdg = {
      enable = true;
      cacheHome = "${config.home.homeDirectory}/.cache";
      configHome = "${config.home.homeDirectory}/.config";
      dataHome = "${config.home.homeDirectory}/.local/share";
      stateHome = "${config.home.homeDirectory}/.local/state";
      autostart.enable = true;
    };

    programs = {
      home-manager.enable = true;
    };
    services = {
    };

    home.packages =
      (with pkgs; [
        ])
      ++ (with pkgs-unstable; [
        ])
      ++ (with pkgs-oldstable; [
        ]);
  };
}
