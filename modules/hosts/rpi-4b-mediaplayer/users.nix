{self, ...}: {
  flake.modules.nixos.rpi-4b-mediaplayer-carl = {
    config,
    pkgs,
    ...
  }: {
    users.mutableUsers = false;
    users.users.carl = {
      isNormalUser = true;
      uid = 1001;
      description = "Carl Mitchell";
      group = "users";
      extraGroups = ["wheel" "networkmanager" "dialout" "plugdev" "docker" "audio"];
      openssh.authorizedKeys.keys = config.systemConstants.sshAuthorizedKeys;
    };
  };
}
