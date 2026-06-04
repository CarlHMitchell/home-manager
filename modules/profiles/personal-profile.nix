# Declares personal-device options.
# Set these in the relevant host config (e.g. hosts/carl-nixos/default.nix)
{...}: {
  flake.modules.homeManager.personal-profile = {lib, ...}: {
    options.personal = {
      gitEmail = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Personal email for git and jj commits";
      };

      programs = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable personal-only programs";
      };

      services = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable personal-only services";
      };

      packages = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable personal-only packages";
      };

      modules = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable personal-only modules";
      };
    };
  };
}
