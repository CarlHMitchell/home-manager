{...}: {
  flake.modules.homeManager.llms = {
    config,
    lib,
    pkgs,
    inputs,
    ...
  }: {
    home.packages = with pkgs; [
      claude-code
      claude-monitor
#       inputs.lemonade-nix.packages.${pkgs.system}.default
    ];
  };
}
