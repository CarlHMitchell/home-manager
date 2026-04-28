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
