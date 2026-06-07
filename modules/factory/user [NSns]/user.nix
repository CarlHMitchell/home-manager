{self, ...}: {
  config.flake.factory.user = username: isAdmin: hostname: {
    nixos."${username}" = {
      lib,
      pkgs,
      ...
    }: {
      users.users."${username}" = {
        isNormalUser = true;
        home = "/home/${username}";
        extraGroups = lib.optionals isAdmin [
          "wheel"
        ];
        shell = pkgs.zsh;
      };
      programs.zsh.enable = true;

      home-manager.users."${username}".imports = let
        hostKey = "${username}@${hostname}";
      in
        if self.modules.homeManager ? ${hostKey}
        then [self.modules.homeManager.${hostKey}]
        else [self.modules.homeManager.${username}];
    };

    systemManager."${username}" = {
      lib,
      pkgs,
      ...
    }: {
      users.users."${username}" = {
        isNormalUser = true;
        home = "/home/${username}";
        extraGroups = lib.optionals isAdmin [
          "wheel"
        ];
        shell = pkgs.zsh;
      };
      programs.zsh.enable = true;
    };
  };
}
