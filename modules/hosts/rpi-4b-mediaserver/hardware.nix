{...}: {
  flake.modules.nixos.rpi-4b-mediaserver-hardware = {
    modulesPath,
    lib,
    ...
  }: {
    # Provides the SD image build (`system.build.sdImage`), the U-Boot/extlinux
    # boot loader, and the / and /boot/firmware filesystems (by label).
    imports = [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ];

    sdImage.compressImage = true;

    # Low-memory board: compressed RAM swap
    zramSwap.enable = true;

    # The installer profile pulled in by the SD image module isn't wanted on a deployed host
    boot.supportedFilesystems.zfs = lib.mkForce false;
    hardware.enableRedistributableFirmware = true;
  };
}
