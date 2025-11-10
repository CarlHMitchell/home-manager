# https://github.com/numtide/system-manager
# To rebuild:
# nix run 'github:numtide/system-manager' -- build --flake '.'
# That will output where the system-manager profile was built.
# E.g. `/nix/store/ly79x5m0rlpvj2j2sx0ambydh47xxyn7-system-manager`
# Run the `bin/actiate` function from that with `sudo` to load any built units.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # https://github.com/NixOS/nixpkgs/blob/e643668fd71b949c53f8626614b21ff71a07379d/nixos/modules/config/nix.nix#L81-L92
  nixConfFormat = pkgs.pkgs-lib.formats.nixConf { };
in
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
    nix.settings = {
      sandbox = true;
      build-users-group = "nixbld";
      # MANAGED BY KTMR/ktmr-installer/roles/nix
      substituters = [
        "http://cache.nixos.org"
        "https://nix-cache.corp.ktdev.io https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-cache.corp.ktdev.io:/xiDfugzrYzUtdUEIvdYBHy48O0169WYHYb/zMdWgLA="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      trusted-users = [ "root" "carl" ];
      allowed-users = [ "*" ];
      # END MANAGED BY KTMR/ktmr-installer/roles/nix
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };

    systemd.services = {
      foo = {
        enable = true;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        wantedBy = ["system-manager.target"];
        script = ''
          ${lib.getBin pkgs.hello}/bin/hello
          echo "We launched the rockets!"
        '';
      };
    };
  };
}
