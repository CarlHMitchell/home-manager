# Dendritic Refactor Plan

Convert the flat, inline flake to a **flake-parts + import-tree** ("dendritic") structure where
every concern lives in its own module file under `modules/`.

## Optional Future Work (not required for a working build)

These are improvements that can follow the core refactor:

| Task | Description |
|------|-------------|
| Adopt `nix-colors` | Wire up the `nix-colors` input for palette-aware theming |
| Adopt `sops-nix` | Add secret management for credentials currently hardcoded (e.g., hashed password in `system/default.nix`) |
| Replace `foo` test service | `systemd.services.foo` and `/etc/foo.conf` are placeholder examples; replace with real system config |
| Multi-host support | If a second machine is added, parameterize `system = "x86_64-linux"` via a `hosts/` directory pattern |

 Done. Here's a summary of what was done and what you need to do next:

  ---
  What changed

  New structure:
  - homes/carl/ — user identity, cross-host packages/programs/services
  - hosts/motive-workstation/ — work packages (slack, embedded hw tools, Motive-specific CLIs), plasma desktop
  workarounds
  - hosts/carl-nixos/system/ — NixOS system config (boot, networking, KDE Plasma, users)
  - hosts/carl-nixos/home.nix — host-specific HM overrides (empty stub, add as needed)
  - modules/nixos.nix — nixosConfigurations."carl-nixos" using HM as a NixOS module
  - modules/home-manager.nix — mkHome helper, renamed key to "carl@motive-workstation"

  Deployment commands going forward:
  # Motive workstation (unchanged mechanism, new flake key)
  home-manager switch --flake .#carl@motive-workstation

  # Personal NixOS machine
  sudo nixos-rebuild switch --flake .#carl-nixos

  Before switching on carl-nixos

  1. Generate hardware config — run on the machine itself:
  sudo nixos-generate-config --show-hardware-config > hosts/carl-nixos/system/hardware-configuration.nix
  2. Copy the font binary — binaries/IosevkaCarl.tar.zstd needs to exist at the same path on carl-nixos before
  running nix flake update iosevka-carl-font
  3. Verify timezone — hosts/carl-nixos/system/default.nix defaults to America/Los_Angeles; adjust if needed

● All four values are set correctly. Done. Here's a summary of what changed:

  New: modules/home/work-profile.nix

  Declares options.work.{gitEmail, awsProfile, ktmrEnabled, jjPrePushCheckerScript} with neutral defaults
  (empty/null/false). Exported as homeModules.work-profile and imported by homes/carl/default.nix.

  hosts/motive-workstation/default.nix

  Sets all four options to their Motive values. carl-nixos gets the defaults (no work integrations).

  Modules updated

  ┌────────────┬─────────────────────────────────────────────────────────────────────────────────────────────────┐
  │   Module   │                                     What's now conditional                                      │
  ├────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ git.nix    │ user.email, gerrit LFS setting, all ~/code/KeepTruckin/kt/ ignore paths                         │
  ├────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ jj.nix     │ [user] email, pushk/checkk aliases                                                              │
  ├────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ bash.nix   │ ktmr/load.sh, KTMR_DIRENV_SKIP_NIX_VERSION_CHECK, KTMR_PATH, AWS_DEFAULT_PROFILE                │
  ├────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ fish.nix   │ KTMR_DIRENV_SKIP_NIX_VERSION_CHECK                                                              │
  ├────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ zsh.nix    │ KTMR_DIRENV_SKIP_NIX_VERSION_CHECK, AWS_PROFILE, ktmr/load.sh, via_changelog, emb/via/ktpc      │
  │            │ aliases                                                                                         │
  ├────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ plasma.nix │ Baloo file indexer exclusion of ~/code/KeepTruckin/                                             │
  └────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────┘

 Clean. Here's a summary of what was done:

  hardware-configuration.nix — replaced the placeholder with the real content: AMD CPU + microcode, nvme/thunderbolt
  initrd modules, btrfs subvolumes (/, /home, /nix), EFI boot partition.

  system/default.nix — merged in:
  - boot.kernelPackages = pkgs.linuxPackages_latest
  - Timezone corrected to America/New_York
  - i18n.extraLocaleSettings with en_DK.UTF-8 for measurement/time/etc.
  - users.users.carl.description
  - system.stateVersion = "26.05"
  - Dropped networking.wireless.enable — NetworkManager already handles WiFi and they conflict

  system/services.nix — merged in:
  - services.xserver.enable = true + Colemak keyboard layout
  - services.pulseaudio.enable = false + security.rtkit.enable = true
  - services.pipewire.alsa.support32Bit = true
  - programs.firefox.enable = true

  system/packages.nix — added vim

  hosts/carl-nixos/home.nix — moved kdePackages.kate here from the NixOS user account packages, where home-manager
  owns user packages
