# https://github.com/numtide/system-manager
# To rebuild:
#   nix run 'github:numtide/system-manager' -- build --flake '.'
# That will output where the system-manager profile was built, e.g.:
#   /nix/store/ly79x5m0rlpvj2j2sx0ambydh47xxyn7-system-manager
# Run bin/activate from that path with sudo to load any built units.
{inputs, ...}: {
  flake.legacyPackages."x86_64-linux".systemConfigs.default = inputs.system-manager.lib.makeSystemConfig {
    modules = [
      (
        {
          config,
          lib,
          pkgs,
          ...
        }: let
          # https://github.com/NixOS/nixpkgs/blob/e643668fd71b949c53f8626614b21ff71a07379d/nixos/modules/config/nix.nix#L81-L92
          nixConfFormat = pkgs.pkgs-lib.formats.nixConf {};
        in {
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
                "https://nix-cache.corp.ktdev.io"
              ];
              trusted-public-keys = [
                "nix-cache.corp.ktdev.io:/xiDfugzrYzUtdUEIvdYBHy48O0169WYHYb/zMdWgLA="
              ];
              trusted-users = ["carl"];
              allowed-users = ["*"];
              # END MANAGED BY KTMR/ktmr-installer/roles/nix
              experimental-features = ["nix-command" "flakes"];
              auto-optimise-store = true;
              download-buffer-size = 524288000;
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

            users.groups."carl" = {
              name = "carl";
            };
            users.users."carl" = {
              group = "carl";
              isNormalUser = true;
              hashedPassword = "$y$j9T$VzoR5TnMIvmGCWcmNIMSP.$y1j94mYHM3m7ih4thLTtrRWRA1VVZfaErcZua7im3I.";
              uid = 1000;
              extraGroups = [
                "dialout"
                "systemd-journal"
                "plugdev"
                "docker"
                "dip"
                "lpadmin"
                "sambashare"
                "sudo"
              ];
            };
          };
        }
      )
    ];
  };
}
