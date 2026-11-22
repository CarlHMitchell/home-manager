{
  inputs,
  self,
  lib,
  ...
}: {
  flake.modules = lib.mkMerge [
    (self.factory.user "mediaplayer" true "rpi-4b-mediaplayer")
    {
      nixos.rpi-4b-mediaplayer = {config, ...}: {
        users.users.mediaplayer = {
          description = "Media player user";
          extraGroups = ["networkmanager" "dialout" "plugdev" "docker" "audio"];
          openssh.authorizedKeys.keys = config.systemConstants.sshAuthorizedKeys;
        };
      };
      homeManager."mediaplayer@rpi-4b-mediaplayer" = {
        config,
        pkgs,
        ...
      }: {
        imports = with self.modules.homeManager; [
          mediaplayer
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
