{inputs, config, ...}: {
  imports = [
    ./packages.nix
    ./programs.nix
    ./services.nix

    inputs.self.homeModules.work-profile
    inputs.self.homeModules.git
    inputs.self.homeModules.xcompose
    inputs.self.homeModules.fish
    inputs.self.homeModules.bash
    inputs.self.homeModules.zsh
    inputs.self.homeModules.zellij
    inputs.self.homeModules.plasma
    inputs.self.homeModules.starship
    inputs.self.homeModules.jj
    inputs.self.homeModules.uv
    inputs.self.homeModules.iosevka-carl
  ];

  home = {
    username = "carl";
    homeDirectory = "/home/carl";
    sessionVariables = {
      # EDITOR = "emacs";
    };
    stateVersion = "25.05";
  };

  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
    autostart.enable = true;
  };

  fonts.fontconfig.enable = true;
}
