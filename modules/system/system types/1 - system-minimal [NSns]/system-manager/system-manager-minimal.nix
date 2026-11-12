{inputs, ...}: {
  # default settings needed for all system-manager configurations

  flake.modules.systemManager.system-minimal = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;

    # Custom settings written to /etc/nix/nix.custom.conf
    nixpkgs.overlays = [
      (_final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          config.allowUnfree = true;
          system = prev.stdenv.hostPlatform.system;
        };
      })
    ];

    environment.systemPackages = with pkgs; [
      bash
      w3m-nographics
      testdisk
      ms-sys
      efibootmgr
      efivar
      parted
      gptfdisk
      ddrescue
      ccrypt
      cryptsetup
      vim
      fuse
      fuse3
      sshfs-fuse
      socat
      screen
      tcpdump
      sdparm
      hdparm
      smartmontools
      pciutils
      usbutils
      nvme-cli
      unzip
      zip
      jq
      zsh
    ];
  };
}
