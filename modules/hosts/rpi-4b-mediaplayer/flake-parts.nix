{inputs, ...}: {
  flake.nixosConfigurations = inputs.self.lib.mkNixos "aarch64-linux" "rpi-4b-mediaplayer";
  flake.homeConfigurations =
    inputs.self.lib.mkHomeManager "aarch64-linux" "carl@rpi-4b-mediaplayer";
}
