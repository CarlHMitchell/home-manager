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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6uxGJ1DLnFasXcRQYp7tM7UL0vVfV+5Fg7IKSxGfuu carl@carl-thinkpad-pw0j0jnb" # carl-thinkpad-pw0j0jnb
      ];
    };
  };
}
