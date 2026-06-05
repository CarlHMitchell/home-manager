{...}: {
  flake.modules.nixos.carl-nixos-filesystem = {...}: {
    fileSystems."/" = {
      device = "/dev/disk/by-partlabel/root"; # nvme0n1p1
      fsType = "btrfs";
      options = ["compress=zstd" "noatime"];
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-partlabel/root"; # nvme0n1p1
      fsType = "btrfs";
      options = ["subvol=home" "compress=zstd" "noatime"];
    };

    fileSystems."/nix" = {
      device = "/dev/disk/by-partlabel/root"; # nvme0n1p1
      fsType = "btrfs";
      options = ["subvol=nix" "compress=zstd" "noatime"];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/DC06-E5E9"; # nvme1n1p1, EFI System Partition
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };

    swapDevices = [];
  };
}
