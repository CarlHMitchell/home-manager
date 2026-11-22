{self, ...}: {
  flake.modules.nixos.rpi-4b-mediaplayer = {
    pkgs,
    lib,
    ...
  }: {
    imports = with self.modules.nixos; [
      system-desktop
      ssh
      rpi-4b-mediaplayer-hardware
      rpi-4b-mediaplayer-filesystem
      rpi-4b-mediaplayer-services
      rpi-4b-mediaplayer-programs
      rpi-4b-mediaplayer-carl
      carl-rpi-4b-mediaplayer # home-manager user config
      tailscale
    ];

    networking = {
      hostName = "rpi-4b-mediaplayer";
      networkmanager.enable = true;
      networkmanager.wifi.powersave = false;
    };

    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than 14d";
      };
      settings.auto-optimise-store = true;
    };

    # Removes "console=ttyAMA0,115200n8", adds snd devices
    boot.kernelParams = lib.mkForce [
      "console=ttyS0,115200n8"
      "console=tty0"
      "root=fstab"
      "loglevel=7"
      "lsm=landlock,yama,bpf"
      "snd_bcm2835.enable_hdmi=1"
      "snd_bcm2835.enable_headphones=1"
    ];

    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
    console.enable = false;
    environment.systemPackages = with pkgs; [
      libraspberrypi
      raspberrypi-eeprom
    ];

    system.stateVersion = "26.05";
  };
}
