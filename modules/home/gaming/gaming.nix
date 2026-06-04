{...}: {
  flake.modules.homeManager.gaming = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      #packages
      discord
    ];
  };
}
