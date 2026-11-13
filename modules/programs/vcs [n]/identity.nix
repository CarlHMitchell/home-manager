# Shared VCS identity option, set by the personal / work profiles and consumed by git and jj.
# Several modules import this; the `key` makes the module system load it only once.
{...}: {
  flake.modules.homeManager.vcs-identity = {
    key = "vcs-identity";
    imports = [
      ({lib, ...}: {
        options.vcs.email = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Email used for git and jj commits. Empty means unset.";
        };
      })
    ];
  };
}
