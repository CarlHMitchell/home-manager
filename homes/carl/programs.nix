# User program configuration (programs.*).
{
  pkgs,
  pkgs-unstable,
  lib,
  ...
}: {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.atuin.enable = true;

  programs.neovim = {
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

  programs.nh = {
    enable = true;
    clean.enable = true;
  };

  programs.ssh.matchBlocks."*".addKeysToAgent = "yes";

  programs.keepassxc = {
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

  programs.jujutsu = {
    enable = true;
    package = pkgs-unstable.jujutsu;
    # config in dotfiles/jj.toml.
    # TODO: Figure out how to escape toml properly
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
    options.background = "dark";
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };

  # programs.vscode = {
  #   enable = true;
  #   package = pkgs.vscode-fhs;
  #   mutableExtensionsDir = true;
  #   profiles.default = {
  #     enableExtensionUpdateCheck = true;
  #     extensions = with pkgs.vscode-extensions; [
  #       bbenoist.nix
  #       ms-vscode.cpptools
  #       yzhang.markdown-all-in-one
  #       ms-python.python
  #       timonwong.shellcheck
  #       twxs.cmake
  #       ms-vscode.cmake-tools
  #       rust-lang.rust-analyzer
  #       mechatroner.rainbow-csv
  #       ms-azuretools.vscode-docker
  #       xaver.clang-format
  #       arrterian.nix-env-selector
  #       mkhl.direnv
  #       zxh404.vscode-proto3
  #       eamodio.gitlens
  #       ms-toolsai.jupyter
  #       ms-toolsai.vscode-jupyter-slideshow
  #       ms-toolsai.vscode-jupyter-cell-tags
  #       ms-toolsai.jupyter-renderers
  #       ms-toolsai.jupyter-keymap
  #       jnoortheen.nix-ide
  #       ms-vscode.makefile-tools
  #       davidanson.vscode-markdownlint
  #       jebbs.plantuml
  #       shd101wyy.markdown-preview-enhanced
  #       visualjj.visualjj
  #     ];
  #   };
  # };
}
