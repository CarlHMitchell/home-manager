{ self, ... }: {
  flake.modules.system-manager.carl-thinkpad-pw0j0jnb = {
    imports = with self.modules.system-manager; [
      system-desktop
    ];
  };
}
