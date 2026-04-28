# Home configuration for carl @ motive workstation.
# Entry point: sets identity and imports all sub-modules.
{inputs, config, ...}: {
  imports = [
    # Concerns split out of the original home.nix
    ./packages.nix
    ./programs.nix
    ./services.nix
    ./desktop.nix

    # Per-application shell/UI configs — each is a flake homeModule declared in modules/home/
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
    # Tracks Home Manager release compatibility — do not change without reading release notes.
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
