{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      # copy_on_select = false;
      copy_command = "wl-copy";
      default_shell = "${pkgs.zsh}/bin/zsh";
    };
  };
}
