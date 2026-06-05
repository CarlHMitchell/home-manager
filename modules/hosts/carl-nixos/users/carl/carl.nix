{
  self,
  lib,
  ...
}: {
  flake.modules = lib.mkMerge [
    (self.factory.user "carl" true "carl-nixos")
    {
      nixos.carl-personal = {config, ...}: {
        users.users.carl = {
          description = "Carl Mitchell";
          extraGroups = ["networkmanager" "dialout" "plugdev" "docker" "audio"];
        };
      };
    }
  ];
}
