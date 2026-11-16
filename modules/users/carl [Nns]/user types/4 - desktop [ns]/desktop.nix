{inputs, ...}: {
  # default settings needed for all homeManagerConfigurations

  flake.modules.homeManager.carl-desktop = {
    config,
    pkgs,
    pkgs-unstable,
    pkgs-oldstable,
    lib,
    ...
  }: {
    imports = with inputs.self.modules.homeManager; [
      carl-cli
      plasma
      kate
      iosevka-carl
      rust
      system-desktop
    ];

    services = {
      syncthing = {
        enable = true;
        # tray.enable = true; # Disabled for now, syncthing-tray-plasma not supported? Plasmoid preferred.
      };
    };

    programs = {
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
            WordCount = 10;
            WordSeparator = "";
          };
        };
      };

      zoxide = {
        enableBashIntegration = true;
        enableFishIntegration = true;
      };

      nh = {
        enable = true;
        clean.enable = true;
      };
    };

    home.packages =
      (with pkgs; [
        android-tools
        qalculate-qt
        kdePackages.okular
        iosevka
        scrcpy
        freecad
        okteta
        kicad
        putty
        wireshark # USB and network capture
        ghidra
        mergiraf
        mediainfo
        gimp
        inkscape
        kdePackages.kdenlive
        obs-studio
        vlc
        wl-clipboard
        zotero
        mermaid-cli
        graphviz
        plantuml
        qdirstat
      ])
      ++ (with pkgs-unstable; [
        ])
      ++ (with pkgs-oldstable; [
        ]);
  };
}
