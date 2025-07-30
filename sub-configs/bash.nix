{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.bash = {
    enable = true;
    initExtra = ''
      if command -v starship >/dev/null; then
        eval "$(starship init bash)"
      else
        echo "Starship not installed"
      fi
      if command -v direnv >/dev/null; then
        eval "$(direnv hook bash)"
      else
        echo "Direnv not installed"
      fi
      if command -v pay-respects >/dev/null; then
        eval "$(pay-respects bash --alias)"
      else
        echo "pay-respects not installed"
      fi
      if [ -f "/home/carl/.config/ktmr/load.sh" ]; then
        source "/home/carl/.config/ktmr/load.sh"
      fi
      export KTMR_DIRENV_SKIP_NIX_VERSION_CHECK="iknowwhatimdoing"
      export KTMR_PATH="/home/carl/code/KeepTruckin/kt"
      export AWS_DEFAULT_PROFILE="keeptruckin"
    '';
    shellAliases = rec {
      ls = "eza --color=auto --group-directories-first --classify";
      la = "${ls} --all";
      ll = "${ls} --all --long --header --group";
    };
  };
}
