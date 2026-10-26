{...}: {
  flake.modules.nixos.rpi-4b-mediaserver-programs = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      git
      vim
      htop
      nfs-utils
    ];
  };
}
