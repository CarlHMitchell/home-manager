{...}: {
  flake.modules.nixos.rpi-4b-mediaplayer-users = {
    config,
    ...
  }: {
    users.mutableUsers = true;
  };
}
