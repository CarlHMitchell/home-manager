{
  config,
  pkgs,
  pkgs-unstable,
  pkgs-oldstable,
  lib,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "carl";
  home.homeDirectory = "/home/carl";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  imports = [
    ./sub-configs/git.nix
    ./sub-configs/xcompose.nix
    ./sub-configs/fish.nix
    ./sub-configs/bash.nix
    ./sub-configs/zsh.nix
    ./sub-configs/zellij.nix
    ./sub-configs/plasma.nix
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages =
    (with pkgs; [
      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
      lazyjj
      jjui
      jj-fzf
      btop
      jetbrains.clion
      jetbrains.pycharm
      slack
      dia
      gimp
      inkscape
      kdePackages.kdenlive
      lyx
      nanovna-saver
      broot
      pay-respects
      oils-for-unix
      minicom
      fzf
      b3sum
      black
      shellcheck
      tree
      binutils
      unzip
      fd
      ripgrep
      obs-studio
      vlc
      nix-index
      any-nix-shell
      zsh
      zsh-z
      zsh-fzf-tab
      zsh-autocomplete
      zsh-you-should-use
      zsh-autosuggestions
      zsh-syntax-highlighting
      nix-zsh-completions
      cod
      jq
      orpie
      bitwise
      strace
      eza
      rustup
      dhex
      segger-ozone
      lnav
      stlink
      usbutils
      saleae-logic-2
      nixpkgs-fmt
      wl-clipboard
      dmidecode
      openocd
      zotero
      fastgron
      mermaid-cli
      graphviz
      plantuml
      vimPlugins.which-key-nvim
      distrobox
      android-tools
      just
      ruff
      ty
      unixtools.xxd
      protoscope
      protobuf
      nanopb
      lsof
      jira-cli-go
      protolint
      gh
      kicad
      input-leap
      mcumgr-client
      systemctl-tui
      atuin
      keepassxc
      qalculate-qt
      alejandra
      nixfmt-tree
      gcc-arm-embedded
      clang-tools
      kdePackages.okular
      dfu-util
      k9s
      k3s
      gcc
      iosevka
      # (iosevka.override {
      #    set = "custom";
      #    privateBuildPlan = {
      #      family = "Iosevka Carl";
      #      spacing = "normal";
      #      serifs = "sans";
      #      noCvSs = true;
      #      variants = {
      #        design = {
      #          capital-q = "crossing";
      #          i = "serifed-flat-tailed";
      #          l = "serifed-flat-tailed";
      #          long-s = "bent-hook-tailed";
      #          zero = "dotted";
      #          one = "base";
      #          two = "straight-neck-serifless";
      #          four = "closed-serifless";
      #          seven = "straight-serifless-crossbar";
      #          eight = "two-circles";
      #          percent = "rings-continuous-slash";
      #        };
      #      };
      #      ligations.inherits = "clike";
      #    };
      # })
      scrcpy
      freecad
      difftastic
      watchman
      typst
      typstyle
      okteta
      age
      pre-commit
    ])
    ++ # Concatenate lists from each pkgs input to form the whole home.packages
    (with pkgs-unstable; [
      uv
      mise
    ])
    ++ (with pkgs-oldstable; [
      ]);

  fonts = {
    fontconfig.enable = true;
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    "${config.xdg.configHome}/starship.toml" = {
      source = dotfiles/starship.toml;
      force = true;
    };
    "${config.xdg.configHome}/jj/config.toml" = {
      source = dotfiles/jj.toml;
      force = true;
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/carl/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

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
  };

  services.ssh-agent.enable = true;
  programs.ssh.matchBlocks."*".addKeysToAgent = "yes";

  programs.jujutsu = {
    enable = true;
    # config in dotfiles/jj.toml.
    # TODO: Figure out how to escape toml properly
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
    options.background = "dark";
  };

  #   programs.vscode = {
  #     enable = true;
  #     package = pkgs.vscode-fhs;
  #     mutableExtensionsDir = true;
  #     profiles.default = {
  #       enableExtensionUpdateCheck = true;
  #       extensions = with pkgs.vscode-extensions; [
  #         bbenoist.nix
  #         ms-vscode.cpptools # Useful, but eats disk space
  #         yzhang.markdown-all-in-one
  #         ms-python.python
  #         timonwong.shellcheck
  #         twxs.cmake
  #         ms-vscode.cmake-tools
  #         rust-lang.rust-analyzer
  #         mechatroner.rainbow-csv
  #         ms-azuretools.vscode-docker
  #         xaver.clang-format
  #         arrterian.nix-env-selector
  #         mkhl.direnv
  #         zxh404.vscode-proto3
  #         eamodio.gitlens
  #         ms-toolsai.jupyter
  #         ms-toolsai.vscode-jupyter-slideshow
  #         ms-toolsai.vscode-jupyter-cell-tags
  #         ms-toolsai.jupyter-renderers
  #         ms-toolsai.jupyter-keymap
  #         jnoortheen.nix-ide
  #         ms-vscode.makefile-tools
  #         davidanson.vscode-markdownlint
  #         jebbs.plantuml
  #         shd101wyy.markdown-preview-enhanced
  #         visualjj.visualjj
  #       ];
  #     };
  #   };

  services.syncthing = {
    enable = true;
    # tray.enable = true; # Disabled for now, syncthing-tray-plasma not supported? Plasmoid preferred.
  };

  # Nicely reload services when changing configs
  systemd.user.startServices = "sd-switch";

  # Workaround for icons to show up in Plasma
  programs.bash.profileExtra = lib.mkAfter ''
    rm -rf ${config.home.homeDirectory}/.local/share/applications/home-manager
    rm -rf ${config.home.homeDirectory}/.icons/nix-icons
    ls ${config.home.homeDirectory}/.nix-profile/share/applications/*.desktop > ${config.home.homeDirectory}/.cache/current_desktop_files.txt
  '';
  home.activation = {
    linkDesktopApplications = {
      after = ["writeBoundary" "createXdgUserDirectories"];
      before = [];
      data = ''
        rm -rf ${config.home.homeDirectory}/.local/share/applications/home-manager
        rm -rf ${config.home.homeDirectory}/.icons/nix-icons
        mkdir -p ${config.home.homeDirectory}/.local/share/applications/home-manager
        mkdir -p ${config.home.homeDirectory}/.icons
        ln -sf ${config.home.homeDirectory}/.nix-profile/share/icons ${config.home.homeDirectory}/.icons/nix-icons

        # Check if the cached desktop files list exists
        if [ -f ${config.home.homeDirectory}/.cache/current_desktop_files.txt ]; then
          current_files=$(cat ${config.home.homeDirectory}/.cache/current_desktop_files.txt)
        else
          current_files=""
        fi

        # Symlink new desktop entries
        for desktop_file in ${config.home.homeDirectory}/.nix-profile/share/applications/*.desktop; do
          if ! echo "$current_files" | grep -q "$(basename $desktop_file)"; then
            ln -sf "$desktop_file" ${config.home.homeDirectory}/.local/share/applications/home-manager/$(basename $desktop_file)
          fi
        done

        # Update desktop database
        ${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.home.homeDirectory}/.local/share/applications
      '';
    };
  };
}
