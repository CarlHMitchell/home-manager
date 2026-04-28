# Declares flake.homeModules as a mergeable option so each modules/home/*.nix
# can contribute its own entry without flake-parts complaining about multiple definitions.
{lib, ...}: {
  options.flake.homeModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = {};
    description = "Home Manager modules exported by this flake.";
  };
}
