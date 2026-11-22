{inputs, ...}: {
  # default settings for CLI tools
  flake.modules.homeManager.user-cli = {
    config,
    pkgs,
    pkgs-unstable,
    pkgs-oldstable,
    lib,
    ...
  }: {
    imports = with inputs.self.modules.homeManager; [
      user-default
      fish
      bash
    ];

    services = {
    };

    programs = {
      starship = {
        enableBashIntegration = true;
        enableFishIntegration = true;
      };

      atuin.enable = true;

      zoxide = {
        enableBashIntegration = true;
        enableFishIntegration = true;
      };
    };

    fonts.fontconfig.enable = true;

    home.packages =
      (with pkgs; [
        inotify-info
        shellcheck
        tree
        binutils
        unzip
        clang-tools
        just
        ruff
        ty
        unixtools.xxd
        protobuf
        distrobox
        k9s
        gcc
        typst
        typstyle
        jdk25_headless
        nixd
        pre-commit
        prek
        broot
        oils-for-unix
        minicom
        cod
        jq
        orpie
        bitwise
        strace
        rustup
        dhex
        lnav
        usbutils
        dmidecode
        fastgron
      ])
      ++ (with pkgs-unstable; [
        mise
      ])
      ++ (with pkgs-oldstable; [
        ]);
  };
}
