{
  flake.modules.generic.systemConstants = {lib, ...}: {
    options.systemConstants = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = {};
    };

    config.systemConstants = {
      adminEmail = "carl@eufalconimorph.com";

      sshAuthorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyOt0kfpxsWk0MUouYfYsucWSLOm45P526SU0d40kGj carl@nixos" # carl-nixos
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6uxGJ1DLnFasXcRQYp7tM7UL0vVfV+5Fg7IKSxGfuu carl@carl-thinkpad-pw0j0jnb" # motive carl-thinkpad-pw0j0jnb
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZuY1nVd2AQTcelvKDpZXobhRiSrC2lk2rXwqk9FY1T carl@carl-thinkpad-pw0j0jnb" # github-personal carl-thinkpad-pw0j0jnb
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFr0pkh4yDvHfJMl9GpCZCsfxlf3NlOUQKF+DX5Gj0j carl@rpi-4b-mediaserver" # rpi-4b-mediaserver
      ];
    };
  };
}
