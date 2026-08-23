{...}: {
  flake.modules.nixos.carl-nixos-programs = {pkgs, ...}: {
    programs = {
      kdeconnect.enable = true;

      zoom-us.enable = true;

      java = {
        enable = true;
        package = pkgs.jdk;
      };

      xwayland.enable = true;
    };
  };
}
