{self, ...}: {
  flake.modules.nixos.rpi-4b-mediaserver = {pkgs, ...}: {
    imports = with self.modules.nixos; [
      system-default
      ssh
      rpi-4b-mediaserver-hardware
      rpi-4b-mediaserver-filesystem
      rpi-4b-mediaserver-services
      rpi-4b-mediaserver-programs
      rpi-4b-mediaserver-carl
    ];

    networking.hostName = "rpi-4b-mediaserver";
    networking.useDHCP = true;

    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than 14d";
      };
      settings.auto-optimise-store = true;
    };

    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };

    system.stateVersion = "26.05";
  };
}
