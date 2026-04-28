{...}: {
  flake.homeModules.bash = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.bash = {
      enable = true;
      initExtra = ''
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
        if command -v mise >/dev/null; then
          eval "$(mise activate bash)"
        else
          echo "mise not installed"
        fi
        if [ -f "/home/carl/.config/ktmr/load.sh" ]; then
          source "/home/carl/.config/ktmr/load.sh"
        fi
        export KTMR_DIRENV_SKIP_NIX_VERSION_CHECK="iknowwhatimdoing"
        export KTMR_PATH="/home/carl/code/KeepTruckin/kt"
        export AWS_DEFAULT_PROFILE="keeptruckin"
        export PATH="$PATH:/home/carl/bin:/home/carl/.local/bin"
        set-konsole-tab-title-type ()
        {
          local _title="$1"
          local _type=''${2:-0}
          [[ -z "''${_title}" ]]               && return 1
          [[ -z "''${KONSOLE_DBUS_SERVICE}" ]] && return 1
          [[ -z "''${KONSOLE_DBUS_SESSION}" ]] && return 1
          qdbus >/dev/null "''${KONSOLE_DBUS_SERVICE}" "''${KONSOLE_DBUS_SESSION}" setTabTitleFormat "''${_type}" "''${_title}"
        }
        set-konsole-tab-title ()
        {
          set-konsole-tab-title-type "$1" && set-konsole-tab-title-type "$1" 1
        }
      '';
      shellAliases = rec {
        ls = "eza --color=auto --group-directories-first --classify";
        la = "${ls} --all";
        ll = "${ls} --all --long --header --group";
      };
    };
  };
}
