{...}: {
  flake.modules.homeManager.libreoffice = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      libreoffice-qt
    ];
  };
}
