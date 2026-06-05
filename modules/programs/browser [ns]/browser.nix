{
  flake.modules.homeManager.browser = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = with pkgs;
      [
        firefox
      ]
      ++ lib.optionals (
        stdenv.hostPlatform.system == "x86_64-linux"
      ) [google-chrome];
    programs.firefox = {
      enable = true;
    };
  };
}
