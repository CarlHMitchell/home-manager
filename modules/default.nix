# https://github.com/numtide/system-manager
# To rebuild:
# nix run 'github:numtide/system-manager' -- build --flake '.'
# That will output where the system-manager profile was built.
# E.g. `/nix/store/ly79x5m0rlpvj2j2sx0ambydh47xxyn7-system-manager`
# Run the `bin/actiate` function from that with `sudo` to load any built units.
{ config, lib, pkgs, ... }:

{
  config = {
    nixpkgs.hostPlatform = "x86_64-linux";

    environment = {
      etc = {
        "foo.conf".text = ''
          launch_the_rockets = true
        '';
      };
      systemPackages = [
        pkgs.ripgrep
        pkgs.fd
        pkgs.neovim
        pkgs.dfu-util
      ];
    };

    systemd.services = {
      foo = {
        enable = true;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        wantedBy = [ "system-manager.target" ];
        script = ''
          ${lib.getBin pkgs.hello}/bin/hello
          echo "We launched the rockets!"
        '';
      };
    };
  };
}
