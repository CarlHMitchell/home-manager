# Declares personal-device options.
# Set these in the relevant host config (e.g. hosts/carl-nixos/default.nix)
{self, ...}: {
  flake.modules.homeManager.personal-profile = {
    config,
    lib,
    ...
  }: {
    imports = [self.modules.homeManager.vcs-identity];

    options.personal = {
      gitEmail = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Personal email for git and jj commits";
      };
    };

    # Default priority, the work profile's email wins when both are set.
    config.vcs.email = lib.mkIf (config.personal.gitEmail != "") (lib.mkDefault config.personal.gitEmail);
  };
}
