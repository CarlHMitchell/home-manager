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

    boot.supportedFilesystems = ["ntfs"];
    fileSystems."/run/media/carl/HDD" = {
      device = "/dev/disk/by-uuid/128EAD1F8EACFC7B";
      fsType = "ntfs3";
      options = ["noatime" "nosuid" "uid=1000"];
    };

    swapDevices = [];
  };
}
