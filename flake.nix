{
  description = "Carl's Home-manager flake";

  inputs = {
    # "Unstable" packages contain updates which may not have been tested, but are closer to upstream.
    # Security updates sometimes hit stable first.
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # "Stable" channel which updates every 6 months. Gets more direct testing than unstable.
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    # Previous "stable" channel, avoid using except when transitioning to new stable.
    nixpkgs-oldstable.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    # Nix module which allows managing per-user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    # Easy module creation
    flake-parts.url = "github:hercules-ci/flake-parts";
    # import entire trees at once
    import-tree.url = "github:vic/import-tree";
    # Pre-built custom Iosevka font (gitignored binary, hashed here for pure eval)
    # When you rebuild the font binary, run `nix flake update iosevka-carl-font` to rehash it before switching.
    iosevka-carl-font = {
      url = "file:///home/carl/.config/home-manager/binaries/IosevkaCarl.tar.zstd";
      flake = false;
    };
  };

  outputs = inputs:
  # flake-parts boilerplate
    inputs.flake-parts.lib.mkFlake {inherit inputs;}
    (inputs.import-tree ./modules);
}
