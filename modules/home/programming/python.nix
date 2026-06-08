{...}: {
  flake.modules.homeManager.uv = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      python3
    ];
  };
}
