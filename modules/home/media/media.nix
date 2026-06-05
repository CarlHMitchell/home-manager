{...}: {
  flake.modules.homeManager.media = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      #packages
      deadbeef
      vlc
    ];
  };
}
