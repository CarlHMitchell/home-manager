{...}: {
  flake.modules.homeManager.yt-dlp = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.yt-dlp = {
      enable = true;
    };
  };
}
