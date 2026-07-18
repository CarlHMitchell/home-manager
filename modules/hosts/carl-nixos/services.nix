{self, ...}: {
  flake.modules.nixos.carl-nixos-services = {pkgs, ...}: {
    services = {
      # X11 (required by some apps even on Wayland sessions)
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
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      printing.enable = true;

      chrony = {
        enable = true;
      };
      samba = {
        enable = true;
        smbd.enable = true;
      };
      hardware = {
        openrgb = {
          enable = true;
          package = pkgs."openrgb-with-all-plugins";
        };
      };
    };
  };
}
