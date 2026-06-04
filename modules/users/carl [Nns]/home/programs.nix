{...}: {
  flake.modules.homeManager.carl-programs = {
    pkgs,
    pkgs-unstable,
    lib,
    config,
    ...
  }: {
    programs = {
      home-manager.enable = true;

      starship = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };

      atuin.enable = true;

      neovim = {
        enable = true;
        defaultEditor = true;
        # https://github.com/theniceboy/nvim
        # https://github.com/mattmc3/neovim-cheatsheet
        # https://docs.google.com/spreadsheets/d/19l4rQdYZfqpMtdTjvCrYLF2z9OsAqahhPunnw7I831s/edit#gid=589401919
        extraConfig = ''
          noremap E J
          noremap n j
          noremap e l
          noremap K N
          noremap k n
          noremap J E
          noremap j e
          noremap N K
          noremap l k
        '';
        viAlias = true;
        vimAlias = true;
        withPython3 = true;
        withRuby = false;
      };

      nh = {
        enable = true;
        clean.enable = true;
      };

      ssh.matchBlocks."*".addKeysToAgent = "yes";

      keepassxc = {
        enable = true;
        autostart = true;
        settings = {
          # For available settings, see https://github.com/keepassxreboot/keepassxc/blob/develop/src/core/Config.cpp
          FdoSecrets.Enabled = true; # Enable Secret Service Integration
          General.ConfigVersion = 2;
          Browser.Enabled = true;
          PasswordGenerator = {
            Type = 1;
            WordCase = 2;
            WordCOunt = 10;
            WordSeparator = "";
          };
        };
      };

      jujutsu = {
        enable = true;
        package = pkgs-unstable.jujutsu;
      };

      difftastic = {
        enable = true;
        git.enable = true;
        options.background = "dark";
      };

      zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        options = ["--cmd cd"];
      };
    };
  };
}
