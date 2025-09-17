{
  description = "Carl's Home-manager flake";

  inputs = {
    # "Unstable" packages contain updates which may not have been tested, but are closer to upstream.
    # Security updates sometimes hit stable first.
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # "Stable" channel which updates every 6 months. Gets more direct testing than unstable.
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    # Previous "stable" channel, avoid using except when transitioning to new stable.
    nixpkgs-oldstable.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    # Nix module which allows managing per-user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Pure-nix utility functions.
    flake-utils.url = "github:numtide/flake-utils";
    # KDE Plasma configuration
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # Colorize shells
    nix-colors.url = "github:misterio77/nix-colors";
    # Secrets management
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixos-like system service configuration on non-nixos systems
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-oldstable,
    home-manager,
    flake-utils,
    plasma-manager,
    nix-colors,
    sops-nix,
    system-manager,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
        pkgs-oldstable = import nixpkgs-oldstable {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        legacyPackages = {
          systemConfigs.extraSpecialArgs = {inherit inputs;};
          systemConfigs.default = system-manager.lib.makeSystemConfig {
            modules = [
              ./modules
            ];
          };
          home-manager.extraSpecialArgs = {inherit inputs;};
          homeConfigurations = {
            "carl" = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = {
                inherit pkgs-unstable;
                inherit pkgs-oldstable;
              };
              modules = [
                inputs.plasma-manager.homeModules.plasma-manager
                ./home.nix
              ];
            };
          };
        };
      }
    );
}
