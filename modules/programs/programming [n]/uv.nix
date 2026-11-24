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
        exclude-newer-package = {
          keeptruckin = "2100-01-01T00:00:00Z";
        };
      };
    };
  };
}
