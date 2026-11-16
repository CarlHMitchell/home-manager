{self, ...}: {
  flake.modules.homeManager."carl@rpi-4b-mediaplayer" = {
    config,
    pkgs,
    ...
  }: {
    imports = with self.modules.homeManager; [
    ];

    personal = {
      gitEmail = "github@eufalconimorph.com";
    };
  };
}
