{inputs, ...}:
let
  mkPkgs = channel: system:
    import inputs.${channel} {
      inherit system;
      config.allowUnfree = true;
    };

  mkHome = {
    user,
    host,
    system ? "x86_64-linux",
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs "nixpkgs" system;
      extraSpecialArgs = {
        inherit inputs;
        pkgs-unstable = mkPkgs "nixpkgs-unstable" system;
        pkgs-oldstable = mkPkgs "nixpkgs-oldstable" system;
      };
      modules = [
        inputs.plasma-manager.homeModules.plasma-manager
        ../homes/${user}
        ../hosts/${host}
      ];
    };
in {
  flake.homeConfigurations = {
    "carl@motive-workstation" = mkHome {
      user = "carl";
      host = "motive-workstation";
    };
  };
}
