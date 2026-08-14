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
      virtiofsd
    ];

    networking.hostName = "carl-nixos";
    networking.networkmanager.enable = true;

    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [
      (final: prev: {
        davinci-resolve = prev.callPackage ../../../packages/davinci-resolve-21/package.nix {};
      })
    ];

    nix = {
      gc.automatic = true;
      settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
        trusted-users = ["root" "carl"];
      };
    };

    environment.systemPackages = with pkgs; [
      git
      vim
      gparted
      virt-viewer
    ];

    virtualisation.spiceUSBRedirection.enable = true;

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
