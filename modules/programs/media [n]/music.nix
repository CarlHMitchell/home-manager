{...}: {
  flake.modules.homeManager.music = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      deadbeef
      easytag
    ];
  };
}
