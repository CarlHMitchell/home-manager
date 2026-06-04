{self, ...}: {
  # Reusable desktop feature profile — importable by future NixOS hosts.
  flake.modules.nixos.linux-desktop = {
    imports = with self.modules.nixos; [
      system-desktop
      systemd-boot
      bluetooth
    ];
  };

  # carl-nixos host configuration.
  flake.modules.nixos.carl-nixos = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = with self.modules.nixos; [
      linux-desktop
      carl-nixos-hardware
      carl-nixos-filesystem
      carl-nixos-services
      carl # user NixOS module (factory-generated + audio group)
      carl-nixos-carl-user # host-specific user settings and personal profile
    ];

    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.hostName = "carl-nixos";
    networking.networkmanager.enable = true;

    time.timeZone = "America/New_York";

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_DK.UTF-8";
      LC_IDENTIFICATION = "en_DK.UTF-8";
      LC_MEASUREMENT = "en_DK.UTF-8";
      LC_MONETARY = "en_DK.UTF-8";
      LC_NAME = "en_DK.UTF-8";
      LC_NUMERIC = "en_DK.UTF-8";
      LC_PAPER = "en_DK.UTF-8";
      LC_TELEPHONE = "en_DK.UTF-8";
      LC_TIME = "en_DK.UTF-8";
    };

    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };

    environment.systemPackages = with pkgs; [
      git
      vim
    ];

    system.stateVersion = "26.05";
  };
}
