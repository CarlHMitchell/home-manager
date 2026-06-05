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
    };
  };
}
