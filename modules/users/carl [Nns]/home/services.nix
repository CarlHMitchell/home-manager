{...}: {
  flake.modules.homeManager.carl-services = {
    config,
    lib,
    ...
  }: {
    services = {
      ssh-agent.enable = true;

      syncthing = {
        enable = true;
        # tray.enable = true; # Disabled for now, syncthing-tray-plasma not supported? Plasmoid preferred.
      };
    };
    # Nicely reload services when changing configs.
    systemd.user.startServices = "sd-switch";
  };
}
