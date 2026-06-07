{self, ...}: {
  flake.modules = {
    nixos.carl = {
      imports = with self.modules.nixos; [
        # developmentEnvironment
      ];
      users.users.carl = {
        group = "users";
      };
    };

    homeManager.carl-base = {
      config,
      pkgs,
      ...
    }: {
      imports = with self.modules.homeManager; [
        system-desktop
        work-profile
        personal-profile
        git
        xcompose
        fish
        bash
        zsh
        zellij
        plasma
        starship
        jj
        uv
        iosevka-carl
        carl-packages
        carl-programs
        carl-services
      ];

      home = {
        username = "carl";
        homeDirectory = "/home/carl";
        stateVersion = "26.05";
        packages = with pkgs; [mediainfo];
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
    };
  };
}
