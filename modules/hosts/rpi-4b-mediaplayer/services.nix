{...}: {
  flake.modules.nixos.rpi-4b-mediaplayer-services = {lib, ...}: {
    systemd.services."getty@".enable = false;
    # mDNS so the Pi (and the NAS) resolve as <hostname>.local
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
      };
    };

    services.chrony.enable = true;

    # Key-only SSH; overrides the shared `ssh` module's password/root defaults
    services.openssh.settings = {
      PasswordAuthentication = lib.mkForce false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = lib.mkForce "no";
    };

    # Plasma desktop (mirrors carl-nixos)
    services = {
      xserver = {
        enable = true;
        xkb = {
          layout = "us";
          variant = "colemak";
        };
      };

      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
      desktopManager.plasma6.enable = true;

      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
    };
  };
}
