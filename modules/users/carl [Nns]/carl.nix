{self, ...}: {
  flake.modules = {
    nixos.carl = {
      imports = with self.modules.nixos; [
        # developmentEnvironment
      ];
      users.users.carl = {
        group = "users";
      };
    };
    homeManager.carl = {
      home = {
        username = "carl";
        stateVersion = "26.05";
      };
    };
  };
}
