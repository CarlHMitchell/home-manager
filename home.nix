{ config, pkgs, ... }:

{
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
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
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
    vscode-fhs
    vscode-extensions.bbenoist.nix
    vscode-extensions.ms-vscode.cpptools # Useful, but eats disk space
    vscode-extensions.yzhang.markdown-all-in-one
    vscode-extensions.ms-python.python
    vscode-extensions.timonwong.shellcheck
    vscode-extensions.twxs.cmake
    vscode-extensions.ms-vscode.cmake-tools
    vscode-extensions.rust-lang.rust-analyzer
    vscode-extensions.mechatroner.rainbow-csv
    vscode-extensions.ms-azuretools.vscode-docker
    vscode-extensions.xaver.clang-format
    vscode-extensions.arrterian.nix-env-selector
    vscode-extensions.mkhl.direnv
    vscode-extensions.zxh404.vscode-proto3
    vscode-extensions.eamodio.gitlens
    vscode-extensions.ms-toolsai.jupyter
    vscode-extensions.ms-toolsai.vscode-jupyter-slideshow
    vscode-extensions.ms-toolsai.vscode-jupyter-cell-tags
    vscode-extensions.ms-toolsai.jupyter-renderers
    vscode-extensions.ms-toolsai.jupyter-keymap
    vscode-extensions.jnoortheen.nix-ide
    vscode-extensions.ms-vscode.makefile-tools
    vscode-extensions.davidanson.vscode-markdownlint
    vscode-extensions.jebbs.plantuml
    vscode-extensions.shd101wyy.markdown-preview-enhanced
    vscode-extensions.github.copilot
    vscode-extensions.visualjj.visualjj
    slack
    dia
    gimp
    inkscape
    kdePackages.kdeconnect-kde
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
    stm32cubemx
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
    uv
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
    mise
    starship
    atuin
  ];

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

  programs.firefox = {
    enable = true;
  };
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "carl.mitchell@gomotive.com";
        name = "Carl Mitchell";
      };
    };
  };

  programs.atuin.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Nicely reload services when changing configs
  systemd.user.startServices = "sd-switch";
}
