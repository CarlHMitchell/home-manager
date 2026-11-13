{self, ...}: {
  flake.modules.systemManager.carl-thinkpad-pw0j0jnb = {config, ...}: {
    imports = with self.modules.systemManager; [
      system-desktop
      carl-user
      memory-pressure
    ];

    # userborn (run by system-manager on every boot) disables users missing from
    # the profile and rewrites sudo's member list. Refuse to build a profile that
    # would lock the admin out. See carl-user for details.
    assertions = [
      {
        assertion = config.users.users ? carl && builtins.elem "sudo" config.users.users.carl.extraGroups;
        message = "carl must be declared (module carl-user) and be in the sudo group, or userborn will lock carl out on activation/boot.";
      }
    ];
  };
}
