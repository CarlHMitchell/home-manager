{inputs, ...}: {
  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    system-manager = {
      url = "github:numtide/system-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
