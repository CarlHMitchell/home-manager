{ ... }: {
  flake.modules.nixos.carl-nixos-services = { ... }: {
    # X11 (required by some apps even on Wayland sessions)
    services.xserver.enable = true;
    services.xserver.xkb = {
      layout = "us";
      variant = "colemak";
    };

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = true;

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    services.printing.enable = true;
    programs.firefox.enable = true;
  };
}
