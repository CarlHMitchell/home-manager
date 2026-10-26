{
  # Lets an x86_64 NixOS host build aarch64-linux closures (e.g. the Raspberry Pi) via QEMU user emulation
  flake.modules.nixos.aarch64-emulation = {
    boot.binfmt.emulatedSystems = ["aarch64-linux"];
    nix.settings.extra-platforms = ["aarch64-linux"];
  };
}
