{...}: {
  flake.modules.homeManager.uv = {
    config,
    pkgs-unstable,
    ...
  }: {
    programs.uv = {
      enable = true;
      package = pkgs-unstable.uv;
      settings = {
        exclude-newer = "7 days";
      };
    };
  };
}
