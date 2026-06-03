{
  inputs,
  ...
}:
{
  # default settings needed for all system-manager configurations

  flake.modules.system-manager.system-minimal =
    {
      pkgs,
      ...
    }:
    {
      nixpkgs.config.allowUnfree = true;

      # Custom settings written to /etc/nix/nix.custom.conf
      
      nixpkgs.overlays = [
        (final: _prev: {
          unstable = import inputs.nixpkgs-unstable {
            inherit (final) config system;
          };
        })
      ];

      environment.systemPackages = with inputs.system-manager.packages.${pkgs.stdenv.hostPlatform.system}; [
        # 
      ];

    };
}
