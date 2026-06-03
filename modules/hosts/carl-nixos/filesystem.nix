{ ... }: {
  flake.modules.nixos.carl-nixos-filesystem = { ... }: {
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/15824873-bc0e-4e6f-8ae9-bb469eea30b2";
      fsType = "btrfs";
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-uuid/15824873-bc0e-4e6f-8ae9-bb469eea30b2";
      fsType = "btrfs";
      options = ["subvol=home"];
    };

    fileSystems."/nix" = {
      device = "/dev/disk/by-uuid/15824873-bc0e-4e6f-8ae9-bb469eea30b2";
      fsType = "btrfs";
      options = ["subvol=nix"];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/DC06-E5E9";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    swapDevices = [];
  };
}
