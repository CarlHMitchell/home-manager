{self, ...}: {
  flake.modules.nixos.rpi-4b-mediaserver-carl = {
    config,
    pkgs,
    ...
  }: {
    users.mutableUsers = false;
    users.users.carl = {
      isNormalUser = true;
      description = "Carl Mitchell";
      group = "users";
      extraGroups = ["wheel"];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = config.systemConstants.sshAuthorizedKeys;
    };
    programs.zsh.enable = true;
  };

  flake.modules.homeManager."carl@rpi-4b-mediaserver" = {
    imports = with self.modules.homeManager; [
      system-cli
    ];

    home.username = "carl";
  };
}
