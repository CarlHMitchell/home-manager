{self, ...}: {
  flake.modules.homeManager."carl@rpi-4b-mediaserver" = {
    config,
    pkgs,
    ...
  }: {
    imports = with self.modules.homeManager; [
      jj
      zsh
    ];

    personal = {
      gitEmail = "github@eufalconimorph.com";
    };

    home.packages = with pkgs; [
    ];
  };
}
