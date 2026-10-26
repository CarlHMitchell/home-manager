{...}: {
  flake.modules.nixos.rpi-4b-mediaserver-services = {lib, ...}: {
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

    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
}
