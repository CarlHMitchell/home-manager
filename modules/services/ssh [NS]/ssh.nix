{
  flake.modules.nixos.ssh = {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "yes";
      };
    };
  };

  flake.modules.systemManager.ssh = {
    services.openssh = {
      enable = true;
    };
  };
}
