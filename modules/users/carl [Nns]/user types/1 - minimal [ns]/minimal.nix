{inputs, ...}: {
  # default settings needed for all homeManagerConfigurations
  flake.modules.homeManager.carl-minimal = {
    config,
    pkgs,
    pkgs-unstable,
    pkgs-oldstable,
    lib,
    ...
  }: {
    home = {
      username = "carl";
      homeDirectory = "/home/${config.home.username}";
      stateVersion = "26.05";
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
