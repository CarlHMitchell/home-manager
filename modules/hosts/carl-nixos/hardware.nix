{...}: {
  flake.modules.nixos.carl-nixos-hardware = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [(modulesPath + "/installer/scan/not-detected.nix")];

    boot = {
      initrd.availableKernelModules = ["nvme" "ahci" "thunderbolt" "xhci_pci" "usbhid" "usb_storage" "sd_mod"];
      initrd.kernelModules = [];
      kernelModules = ["kvm-amd"];
      extraModulePackages = [];
      kernelPackages = pkgs.linuxPackages_latest;
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    hardware = {
      cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      graphics = {
        enable = true;
        enable32Bit = true; # needed for Steam
        extraPackages = with pkgs; [
          rocmPackages.clr.icd
        ];
      };
    };
  };
}
