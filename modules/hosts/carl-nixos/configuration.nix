{self, ...}: {
  flake.modules.nixos.carl-nixos = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = with self.modules.nixos; [
      system-desktop
      systemd-boot
      bluetooth
      carl-nixos-hardware
      carl-nixos-filesystem
      carl-nixos-services
      carl # user NixOS module (factory-generated + audio group)
      carl-personal # host-specific user settings and personal profile
    ];

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
    nixpkgs.overlays = [
      (final: prev: {
        davinci-resolve = prev.callPackage ../../../packages/davinci-resolve-21/package.nix {};
      })
    ];

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };

    environment.systemPackages = with pkgs; [
      git
      vim
      gparted
    ];

    security = {
      rtkit.enable = true;
      sudo = {
        enable = true;
        wheelNeedsPassword = false;
      };
    };

    system.stateVersion = "26.05";
  };
}
