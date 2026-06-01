{...}: {
  # X11 (required by some apps even on Wayland sessions)
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "colemak";
  };

  # Desktop environment
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Printing
  services.printing.enable = true;

  # Browser
  programs.firefox.enable = true;
}
