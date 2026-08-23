{...}: {
  flake.modules.homeManager.llms = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      claude-code
      claude-monitor
    ];
  };
}
