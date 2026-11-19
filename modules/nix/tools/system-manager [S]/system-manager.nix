# https://github.com/numtide/system-manager
# To rebuild:
#   nix run 'github:numtide/system-manager' -- build --flake '.'
# That will output where the system-manager profile was built, e.g.:
#   /nix/store/ly79x5m0rlpvj2j2sx0ambydh47xxyn7-system-manager
# Run bin/activate from that path with sudo to load any built units.
{
  inputs,
  config,
  ...
}: {
  # The system-manager CLI looks up `systemConfigs.<name>`, which nix resolves via
  # legacyPackages.<system>. That attribute can only be defined once, so per-host
  # configs (flake.systemConfigurations, defined in each host module) are merged in here.
  flake.legacyPackages."x86_64-linux".systemConfigs =
    {
      default = inputs.system-manager.lib.makeSystemConfig {
        modules = [
          inputs.self.modules.systemManager.carl-user
          (
            {
              config,
              lib,
              pkgs,
              ...
            }: let
              nixConfFormat = pkgs.pkgs-lib.formats.nixConf {};
            in {
              config = {
                nixpkgs.hostPlatform = "x86_64-linux";

                environment = {
                  # Example setting a config file's contents
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
                    pkgs.helix
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
                  # Example service definition
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
          )
        ];
      };
    }
    // (config.flake.systemConfigurations or {});
}
