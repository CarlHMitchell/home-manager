{
  inputs,
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
        age.secrets."example_secret" = {
          owner = "carl";
          group = "users";
          mode = "600";
          file = "${self.inputs.secrets}/example_secret.age";
        };
      };
    }
  ];
}
