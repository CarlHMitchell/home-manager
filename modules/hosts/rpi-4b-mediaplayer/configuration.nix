{self, ...}: {
  flake.modules.nixos.rpi-4b-mediaplayer = {pkgs, ...}: {
    imports = with self.modules.nixos; [
      system-default
      ssh
      rpi-4b-mediaplayer-hardware
      rpi-4b-mediaplayer-filesystem
      rpi-4b-mediaplayer-services
      rpi-4b-mediaplayer-programs
      rpi-4b-mediaplayer-carl
      carl-rpi-4b-mediaplayer # home-manager user config
      tailscale
    ];

    networking.hostName = "rpi-4b-mediaplayer";
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
