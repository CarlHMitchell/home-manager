{
  inputs,
  self,
  lib,
  ...
}: {
  flake.modules = lib.mkMerge [
    (self.factory.user "carl" true "rpi-4b-mediaplayer")
    {
      nixos.rpi-4b-mediaplayer = {config, ...}: {
        users.users.carl = {
          uid = 1001;
          description = "Carl Mitchell";
          extraGroups = ["networkmanager" "dialout" "plugdev" "docker" "audio"];
          openssh.authorizedKeys.keys = config.systemConstants.sshAuthorizedKeys;
        };
      };
      homeManager."carl@rpi-4b-mediaplayer" = {
        config,
        pkgs,
        ...
      }: {
        imports = with self.modules.homeManager; [
          carl
          system-desktop
          personal-profile
          user-default
          plasma-lightweight
          helix
          media
        ];

        personal = {
          gitEmail = "github@eufalconimorph.com";
        };
      };
    }
  ];
}
