{self, ...}: {
  flake.modules.homeManager."carl@rpi-4b-mediaplayer" = {
    config,
    pkgs,
    ...
  }: {
    imports = with self.modules.homeManager; [
      system-desktop
      personal-profile
      carl-default
      plasma
      helix
    ];

    personal = {
      gitEmail = "github@eufalconimorph.com";
    };

    home.username = "carl";

    home.packages = with pkgs; [
      vlc
    ];
  };
}
