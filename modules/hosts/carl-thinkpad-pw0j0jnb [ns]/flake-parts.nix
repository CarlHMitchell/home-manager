{inputs, ...}: {
  flake.homeConfigurations =
    inputs.self.lib.mkHomeManager "x86_64-linux" "carl@carl-thinkpad-pw0j0jnb";

  flake.systemConfigurations =
    inputs.self.lib.mkSystemManager "x86_64-linux" "carl-thinkpad-pw0j0jnb";
}
