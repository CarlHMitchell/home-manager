{
  inputs,
  self,
  ...
}: {
  flake.modules.nixos.carl-personal = {config, ...}: {
    #     imports = with inputs.self.modules.nixos;
    #     with inputs.self.factory; [
    #       carl
    #     ];
    users.users.carl = {
      description = "Carl Mitchell";
      extraGroups = ["networkmanager" "dialout" "plugdev" "docker"];
    };

    # Host-specific home-manager values (gitEmail, feature flags).
    # Base wiring (useGlobalPkgs, useUserPackages, users.carl.imports) is
    # handled by the home-manager tool module and the user factory.
    home-manager.users.carl = {
      imports = [
        {
          personal = {
            gitEmail = "github@eufalconimorph.com";
            programs = true;
            services = true;
            packages = true;
          };
        }
      ];
    };
  };
}
