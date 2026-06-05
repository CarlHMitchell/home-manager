{self, ...}: {
  flake.modules.homeManager."carl@carl-nixos" = {config, pkgs, ...}: {
    imports = with self.modules.homeManager; [
      carl-base
      browser
      media
    ];

    personal = {
      gitEmail = "github@eufalconimorph.com";
    };

    home.packages = with pkgs; [
          kdePackages.kate
          direnv
          steam
          steam-run
          davinci-resolve
          discord
        ];
  };
}
