{...}: {
  flake.modules.homeManager.node = {
    config,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      lazynpm
      zsh-better-npm-completion
    ];
    programs.npm.enable = true;
  };
}
