let
  genericPackages = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      git
      zellij
      home-manager
    ];
  };
in {
  flake.modules.nixos.cli-tools = {pkgs, ...}: {
    imports = [
      genericPackages
    ];
    environment.systemPackages = [pkgs.jujutsu];
  };

  flake.modules.systemManager.cli-tools = {
    imports = [
      genericPackages
    ];
  };
}
