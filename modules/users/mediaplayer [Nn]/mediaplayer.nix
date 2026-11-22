{self, ...}: {
  flake.modules = {
    nixos.mediaplayer = {
      imports = with self.modules.nixos; [
        # developmentEnvironment
      ];
      users.users.mediaplayer = {
        group = "users";
      };
    };
    homeManager.mediaplayer = {
      home = {
        username = "mediaplayer";
        stateVersion = "26.05";
      };
    };
  };
}
