{inputs, ...}:
let
  mkPkgs = channel: system:
    import inputs.${channel} {
      inherit system;
      config.allowUnfree = true;
    };
in {
  flake.nixosConfigurations."carl-nixos" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      inputs.home-manager.nixosModules.home-manager
      {
        # Share NixOS pkgs with home-manager — avoids double instantiation.
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit inputs;
          pkgs-unstable = mkPkgs "nixpkgs-unstable" "x86_64-linux";
          pkgs-oldstable = mkPkgs "nixpkgs-oldstable" "x86_64-linux";
        };
        home-manager.users.carl = {
          imports = [
            inputs.plasma-manager.homeModules.plasma-manager
            ../homes/carl
            ../hosts/carl-nixos/home.nix
          ];
        };
      }
      ../hosts/carl-nixos/system
    ];
  };
}
