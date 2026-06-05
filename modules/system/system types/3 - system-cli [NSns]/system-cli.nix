{inputs, ...}: {
  # expansion of default system with basic system settings & cli-tools

  flake.modules.nixos.system-cli = {
    imports = with inputs.self.modules.nixos; [
      system-default

      ssh
      firmware
      cli-tools
    ];
  };

  flake.modules.systemManager.system-cli = {
    imports = with inputs.self.modules.systemManager; [
      system-default

      ssh
      cli-tools
    ];
  };

  flake.modules.homeManager.system-cli = {
    imports = with inputs.self.modules.homeManager; [
      system-default

      shell
    ];
  };
}
