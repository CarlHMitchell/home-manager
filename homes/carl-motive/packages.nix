# System-wide user packages, grouped by nixpkgs channel.
{
  pkgs,
  pkgs-unstable,
  pkgs-oldstable,
  ...
}: {
  home.packages =
    (with pkgs; [
      lazyjj
      jjui
      jj-fzf
      btop
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
      prek
      can-utils
      ghidra
      mergiraf
      nuget
      nix-output-monitor
      gerrit
    ])
    ++ (with pkgs-unstable; [
      uv
      mise
      zed-editor
    ])
    ++ (with pkgs-oldstable; [
      ]);
}
