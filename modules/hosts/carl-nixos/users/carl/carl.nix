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
          openssh.authorizedKeys.keys = config.systemConstants.sshAuthorizedKeys;
        };
        age.secrets."example_secret" = {
          owner = "carl";
          group = "users";
          mode = "600";
          file = "${self.inputs.secrets}/example_secret.age";
        };
      };
      homeManager."carl@carl-nixos" = {
        config,
        pkgs,
        ...
      }: {
        imports = with self.modules.homeManager; [
          carl
          user-desktop
          browser
          media
          music
          gaming
          photo_editing
          llms
          github
          yt-dlp
          libreoffice
          personal-profile
          tailscale-systray
          kate
        ];

        personal = {
          gitEmail = "github@eufalconimorph.com";
        };

        home.packages = with pkgs; [
          direnv
          steam-run
          onlyoffice-desktopeditors
          roccat-tools
          zola
          veracrypt
        ];

        services.kdeconnect = {
          enable = true;
        };
      };
    }
  ];
}
