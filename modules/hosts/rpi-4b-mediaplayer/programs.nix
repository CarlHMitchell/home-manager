{...}: {
  flake.modules.nixos.rpi-4b-mediaplayer-programs = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      git
      vim
      htop
      cifs-utils
      eza
      mise
      direnv
      pay-respects
      nix-output-monitor
      jujutsu
    ];
  };
}
