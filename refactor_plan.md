# Dendritic Refactor Plan

Convert the flat, inline flake to a **flake-parts + import-tree** ("[dendritic](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/blob/main/README.md)") structure where every concern lives in its own module file under `modules/`. Other than the main flake.nix, any custom packages under `packages/`, and any secrets under `secrets/`, all files should be flake-parts modules.

Adopt `agenix`: Add secret management for credentials currently hardcoded (e.g., hashed password.

Importantly, relative paths should not be needed. Every file (other than flake.nix) should be a flake-parts module under `modules/`, so it should be possible to freely move files without breaking the configuration. Read the Doc-Steve dendritic guide for details.

Deployment commands going forward:
  # Motive workstation
  home-manager switch --flake .#carl@carl-thinkpad-pw0j0jnb

  # Personal NixOS machine
  sudo nixos-rebuild switch --flake .#carl-nixos
