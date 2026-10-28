{self, ...}: {
  flake.modules.systemManager.carl-thinkpad-pw0j0jnb = {
    imports = with self.modules.systemManager; [
      system-desktop
    ];
  };
}
