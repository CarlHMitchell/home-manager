{self, ...}: {
  flake.modules.nixos.rpi-4b-mediaplayer-carl = {
    config,
    pkgs,
    ...
  }: {
    users.mutableUsers = false;
    users.users.carl = {
      isNormalUser = true;
      description = "Carl Mitchell";
      group = "users";
      extraGroups = ["wheel" "networkmanager" "dialout" "plugdev" "docker" "audio"];
      openssh.authorizedKeys.keys = config.systemConstants.sshAuthorizedKeys;
    };
  };

  flake.modules.homeManager."carl@rpi-4b-mediaplayer" = {
    imports = with self.modules.homeManager; [
      system-cli
      personal-profile
      carl-default
    ];

    home.username = "carl";
  };
}
