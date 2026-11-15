{self, ...}: {
  flake.modules.homeManager."carl@carl-nixos" = {
    config,
    pkgs,
    ...
  }: {
    imports = with self.modules.homeManager; [
      carl-desktop
      browser
      media
      gaming
      photo_editing
      llms
      github
      yt-dlp
      libreoffice
      personal-profile
      tailscale-systray
    ];

    personal = {
      gitEmail = "github@eufalconimorph.com";
    };

    home.packages = with pkgs; [
      kdePackages.kate
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
