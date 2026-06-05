{inputs, ...}: {
  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "carl-nixos";
  flake.homeConfigurations =
    inputs.self.lib.mkHomeManager "x86_64-linux" "carl@carl-nixos";
}
