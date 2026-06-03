{
  inputs,
  ...
}:
{
  # expansion of cli system for desktop use

  flake.modules.nixos.system-desktop = {
    imports = with inputs.self.modules.nixos; [
      system-cli
      printing
    ];
  };

  flake.modules.system-manager.system-desktop = {
    imports = with inputs.self.modules.system-manager; [
      system-cli
      printing
    ];
  };
  flake.modules.homeManager.system-desktop = {
    imports = with inputs.self.modules.homeManager; [
      system-cli
      browser
    ] ++ [
      inputs.plasma-manager.homeModules.plasma-manager
    ];
  };
}
