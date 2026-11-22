{...}: {
  flake.modules.homeManager.media = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      vlc
    ];
  };
}
