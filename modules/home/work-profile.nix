# Declares work-specific options consumed by shell and git modules.
# Set these in the relevant host config (e.g. hosts/motive-workstation/default.nix).
{...}: {
  flake.homeModules.work-profile = {lib, ...}: {
    options.work = {
      gitEmail = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Work email for git and jj commits.";
      };

      awsProfile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "AWS profile name to export as AWS_PROFILE / AWS_DEFAULT_PROFILE.";
      };

      ktmrEnabled = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Enable KTMR-specific shell integrations: sources ~/.config/ktmr/load.sh,
          sets KTMR_DIRENV_SKIP_NIX_VERSION_CHECK and KTMR_PATH, adds kt repo
          shell aliases, and includes kt-specific git ignore paths and LFS config.
        '';
      };

      jjPrePushCheckerScript = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to a prek checker script. Enables the pushk/checkk jj aliases when non-null.";
      };
    };
  };
}
