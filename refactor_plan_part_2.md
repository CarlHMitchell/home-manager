# Refactoring Plan: Full Dendritic Conversion (Part 2)

## Current State

The repo is in a transitional state. The `modules/` tree is largely dendritic — most feature
modules declare `flake.modules.*` correctly. The blocking issues are:

1. **Dual NixOS assembly conflict**: Both `modules/nixos.nix` (old-style, path-based) and
   `modules/hosts/carl-nixos/flake-parts.nix` (new-style, `lib.mkNixos`) both try to export
   `flake.nixosConfigurations."carl-nixos"`. One must be eliminated.

2. **`homes/` and `hosts/` top-level dirs**: These live outside `modules/`, are imported via
   hardcoded relative paths (`../homes/${user}`, `../hosts/${host}`), and are the last reason
   the old orchestration files (`modules/nixos.nix`, `modules/home-manager.nix`) still exist.

3. **Standalone HM config (motive-workstation) has no dendritic home**: The `carl@motive-workstation`
   config is assembled entirely in `modules/home-manager.nix` with no corresponding host module
   under `modules/hosts/`.

4. **`lib.mkHomeManager` doesn't pass multi-channel pkgs**: `homes/carl/packages.nix` uses
   `pkgs-unstable` and `pkgs-oldstable` as special args, but `modules/nix/flake-parts/lib.nix`'s
   `mkHomeManager` only passes `inputs.nixpkgs.legacyPackages.${system}`.

5. **`homes/carl/default.nix` references flat module keys**: It uses `inputs.self.modules.git`,
   `inputs.self.modules.bash`, etc. — flat keys rather than the nested
   `inputs.self.modules.homeManager.*` namespace used everywhere else. Once `homes/carl/` moves
   inside `modules/` as a proper `flake.modules.homeManager.*` declaration, these references must
   be updated.

---

## Target State

```
modules/
├── nix/flake-parts/           # (unchanged — lib.nix updated for multi-channel)
├── hosts/
│   ├── carl-nixos/            # (mostly exists — add system/ content, drop top-level hosts/)
│   │   ├── configuration.nix  # flake.modules.nixos.carl-nixos (replaces hosts/carl-nixos/system/)
│   │   ├── flake-parts.nix    # exports flake.nixosConfigurations."carl-nixos" (already correct)
│   │   ├── hardware.nix       # (already exists in modules/)
│   │   └── filesystem.nix     # (already exists in modules/)
│   └── carl-thinkpad-pw0j0jnb [ns]/   # replaces hosts/motive-workstation/ + home-manager.nix
│       ├── flake-parts.nix    # exports homeConfigurations."carl@carl-thinkpad-pw0j0jnb" and
│       │                      #   systemConfigurations."carl-thinkpad-pw0j0jnb"
│       ├── homeManager.nix    # flake.modules.homeManager.carl@carl-thinkpad-pw0j0jnb
│       ├── packages.nix       # declares flake.modules.homeManager.thinkpad-packages
│       └── desktop.nix        # declares flake.modules.homeManager.thinkpad-desktop
├── users/
│   └── carl [Nns]/
│       ├── carl.nix           # (extend to absorb homes/carl/default.nix base config)
│       ├── home/              # NEW — homes/carl/ content migrated here as flake-parts modules
│       │   ├── packages.nix   # declares flake.modules.homeManager.carl-packages
│       │   ├── programs.nix   # declares flake.modules.homeManager.carl-programs
│       │   └── services.nix   # declares flake.modules.homeManager.carl-services
│       └── flake-parts.nix    # (already exports homeConfigurations."carl" — keep as-is)
├── profiles/                  # (unchanged)
├── home/                      # (unchanged)
├── programs/                  # (unchanged — but normalize flat module refs to homeManager.*)
├── services/                  # (unchanged)
└── system/                    # (unchanged)

# DELETED:
# homes/                       <- merged into modules/users/carl [Nns]/
# hosts/                       <- merged into modules/hosts/
# modules/nixos.nix            <- replaced by modules/hosts/carl-nixos/flake-parts.nix
# modules/home-manager.nix     <- replaced by modules/hosts/carl-thinkpad-pw0j0jnb [ns]/flake-parts.nix
```

---

## Step-by-Step Plan

### Step 1 — Introduce `pkgs-channels` and `plasma-manager` as HM modules

The [dendritic guide](https://github.com/mightyiam/dendritic/blob/master/README.md) identifies
`specialArgs`/`extraSpecialArgs` as an anti-pattern: values injected this way bypass the module
system and cannot be overridden by any module. The alternative is `_module.args`, set from
*inside* a module.

The key: every file in `modules/` is a flake-parts module whose outer function already receives
`inputs`. Inner NixOS/HM modules defined within that function can *close over* `inputs` from the
outer scope — no `specialArgs` needed.

**New file: `modules/nix/tools/pkgs-channels [ns]/pkgs-channels.nix`**

```nix
{ inputs, ... }: {
  flake.modules.homeManager.pkgs-channels = { pkgs, ... }: {
    _module.args.pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit (pkgs) system;
      config.allowUnfree = true;
    };
    _module.args.pkgs-oldstable = import inputs.nixpkgs-oldstable {
      inherit (pkgs) system;
      config.allowUnfree = true;
    };
  };
}
```

`inputs` is captured from the outer flake-parts scope. The inner HM module sets `_module.args`,
making `pkgs-unstable` and `pkgs-oldstable` available as regular function arguments to all
downstream modules — no `extraSpecialArgs` anywhere.

Include `pkgs-channels` in the `system-default` homeManager module so it is inherited by all
system types:

```nix
# modules/system/system types/2 - system-default [NSns]/homeManager/homeManager-default.nix
flake.modules.homeManager.system-default = {
  imports = with inputs.self.modules.homeManager; [
    system-minimal
    pkgs-channels
    # ... existing imports
  ];
};
```

**Move `plasma-manager` injection into `system-desktop`**

`plasma-manager` is currently hardcoded into the old orchestration files. It is a HM module and
belongs in the module hierarchy, not in the assembler. Add it to `system-desktop` homeManager:

```nix
# modules/system/system types/4 - system-desktop [NSns]/homeManager/homeManager-desktop.nix
{ inputs, ... }: {
  flake.modules.homeManager.system-desktop = {
    imports = with inputs.self.modules.homeManager; [
      system-cli
    ] ++ [
      inputs.plasma-manager.homeModules.plasma-manager
    ];
  };
}
```

`inputs.plasma-manager` is closed over from the outer flake-parts scope, same pattern.

**`lib.mkHomeManager` stays simple — no `extraSpecialArgs`:**

```nix
mkHomeManager = system: name: {
  ${name} = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { inherit system; config.allowUnfree = true; };
    modules = [ inputs.self.modules.homeManager.${name} ];
  };
};
```

The same applies to `carl-nixos` (HM-as-NixOS-module in Step 3): omit
`home-manager.extraSpecialArgs` entirely. `pkgs-unstable` and `pkgs-oldstable` reach HM modules
via the `pkgs-channels` module, which is already included through `system-default`.

---

### Step 2 — Migrate `homes/carl/` into `modules/users/carl [Nns]/`

Move the three files from `homes/carl/` to `modules/users/carl [Nns]/home/` and **wrap each
one's content in a `flake.modules` declaration** so `import-tree` picks them up as flake-parts
modules, not bare HM modules.

**`modules/users/carl [Nns]/home/packages.nix`:**
```nix
{...}: {
  flake.modules.homeManager.carl-packages = { config, lib, pkgs, pkgs-unstable, pkgs-oldstable, ... }: {
    # verbatim content of homes/carl/packages.nix goes here
    home.packages = ...;
  };
}
```

Apply the same wrapper to `programs.nix` → `flake.modules.homeManager.carl-programs` and
`services.nix` → `flake.modules.homeManager.carl-services`.

The base config from `homes/carl/default.nix` (username, homeDirectory, stateVersion, xdg,
fonts, and all the `inputs.self.modules.*` imports) must become part of
`flake.modules.homeManager.carl`. The cleanest place is `modules/users/carl [Nns]/carl.nix`, in
the existing `homeManager.carl` block.

**Updated `modules/users/carl [Nns]/carl.nix`** (homeManager.carl section):

```nix
homeManager.carl = { config, inputs, ... }: {
  imports = with inputs.self.modules.homeManager; [
    system-desktop
    work-profile      # <- update from flat inputs.self.modules.work-profile
    personal-profile  # <- update from flat inputs.self.modules.personal-profile
    git
    xcompose
    fish
    bash
    zsh
    zellij
    plasma
    starship
    jj
    uv
    iosevka-carl
    carl-packages
    carl-programs
    carl-services
  ];

  home = {
    username = "carl";
    homeDirectory = "/home/carl";
    stateVersion = "26.05";
  };

  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
    autostart.enable = true;
  };

  fonts.fontconfig.enable = true;
};
```

**Key change:** Replace all `inputs.self.modules.X` (flat) references with
`inputs.self.modules.homeManager.X` (nested). This requires verifying each program module
(`git`, `fish`, `bash`, etc.) actually exports under `homeManager.*`. Check each file in
`modules/programs/` and `modules/home/` and rename any that still export at the flat level.

---

### Step 3 — Fold `hosts/carl-nixos/` top-level into `modules/hosts/carl-nixos/`

`hosts/carl-nixos/system/default.nix` contains:
- kernel/bootloader settings (`boot.loader.*`, `boot.kernelPackages`)
- locale/timezone
- `networking.hostName = "carl-nixos"`
- `nixpkgs.config.allowUnfree`
- `nix.settings`
- `users.users.carl` (groups, shell)
- `programs.zsh.enable`
- `system.stateVersion`

This content should be merged into `flake.modules.nixos.carl-nixos` in
`modules/hosts/carl-nixos/configuration.nix`. Currently `configuration.nix` only declares
`flake.modules.nixos.linux-desktop`. Rename or split:

- Rename `flake.modules.nixos.linux-desktop` → `flake.modules.nixos.carl-nixos` and add the
  system-level settings. The `linux-desktop` profile (importing system-desktop + systemd-boot +
  bluetooth) can remain as a standalone module exported separately, with `carl-nixos` importing it.

```nix
# modules/hosts/carl-nixos/configuration.nix (new structure)
{inputs, ...}: {
  # Reusable linux-desktop profile (keep for potential future hosts)
  flake.modules.nixos.linux-desktop = {
    imports = with inputs.self.modules.nixos; [
      system-desktop
      systemd-boot
      bluetooth
    ];
  };

  # carl-nixos host config
  flake.modules.nixos.carl-nixos = { pkgs, inputs, ... }: {
    imports = with inputs.self.modules.nixos; [
      linux-desktop
      # hardware, filesystem already imported via modules/hosts/carl-nixos/hardware.nix etc.
    ];

    # --- content from hosts/carl-nixos/system/default.nix ---
    boot.kernelPackages = pkgs.linuxPackages_latest;
    networking.hostName = "carl-nixos";
    networking.networkmanager.enable = true;
    time.timeZone = "America/New_York";
    i18n = { ... };  # copy verbatim
    nixpkgs.config.allowUnfree = true;
    nix.settings = { ... };
    users.users.carl = { isNormalUser = true; ... };
    programs.zsh.enable = true;
    system.stateVersion = "26.05";

    # home-manager-as-module wiring (was in modules/nixos.nix)
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = {
      inherit inputs;
      pkgs-unstable = import inputs.nixpkgs-unstable { system = "x86_64-linux"; config.allowUnfree = true; };
      pkgs-oldstable = import inputs.nixpkgs-oldstable { system = "x86_64-linux"; config.allowUnfree = true; };
    };
    home-manager.users.carl = {
      imports = [ inputs.self.modules.homeManager.carl ];
    };
  };
}
```

Also move `hosts/carl-nixos/system/hardware-configuration.nix`, `packages.nix`, and `services.nix`
into `modules/hosts/carl-nixos/` (or merge packages/services content into the host module if small
enough).

The personal profile settings from `hosts/carl-nixos/home.nix`:
```nix
personal = { gitEmail = "github@eufalconimorph.com"; programs = true; services = true; packages = true; };
```
should move into the `home-manager.users.carl` imports block as an inline config module.

---

### Step 4 — Create `modules/hosts/carl-thinkpad-pw0j0jnb [ns]/`

This is the replacement for both parts of `modules/home-manager.nix` and `hosts/motive-workstation/`.

Move `hosts/motive-workstation/packages.nix` and `hosts/motive-workstation/desktop.nix` into
this new directory and **wrap each in a `flake.modules` declaration**:

**`modules/hosts/carl-thinkpad-pw0j0jnb [ns]/packages.nix`:**
```nix
{...}: {
  flake.modules.homeManager.thinkpad-packages = { pkgs, ... }: {
    # verbatim content of hosts/motive-workstation/packages.nix goes here
    home.packages = ...;
  };
}
```

**`modules/hosts/carl-thinkpad-pw0j0jnb [ns]/desktop.nix`:**
```nix
{...}: {
  flake.modules.homeManager.thinkpad-desktop = { pkgs, ... }: {
    # verbatim content of hosts/motive-workstation/desktop.nix goes here
  };
}
```

**`modules/hosts/carl-thinkpad-pw0j0jnb [ns]/homeManager.nix`:**
```nix
{inputs, ...}: {
  flake.modules.homeManager."carl@carl-thinkpad-pw0j0jnb" = { config, inputs, ... }: {
    imports = with inputs.self.modules.homeManager; [
      carl              # base carl home config
      thinkpad-packages
      thinkpad-desktop
    ];

    work = {
      gitEmail = "carl.mitchell@gomotive.com";
      awsProfile = "keeptruckin";
      ktmrEnabled = true;
      jjPrePushCheckerScript = "${config.home.homeDirectory}/.config/home-manager/scripts/prek_ktmr.sh";
    };
  };
}
```

**`modules/hosts/carl-thinkpad-pw0j0jnb [ns]/flake-parts.nix`:**
```nix
{inputs, ...}: {
  flake.homeConfigurations =
    inputs.self.lib.mkHomeManager "x86_64-linux" "carl@carl-thinkpad-pw0j0jnb";
  # Add systemConfigurations when system-manager wiring is ready:
  # flake.systemConfigurations =
  #   inputs.self.lib.mkSystemManager "x86_64-linux" "carl-thinkpad-pw0j0jnb";
}
```

---

### Step 5 — Delete old orchestration files

Once Steps 1–4 are complete and `nix flake check` passes:

- **Delete `modules/nixos.nix`** — replaced by `modules/hosts/carl-nixos/flake-parts.nix`
- **Delete `modules/home-manager.nix`** — replaced by `modules/hosts/carl-thinkpad-pw0j0jnb [ns]/flake-parts.nix`
- **Delete `homes/`** — content now in `modules/users/carl [Nns]/home/`
- **Delete `hosts/`** — content now in `modules/hosts/`

---

### Step 6 — Verify module namespace consistency

Audit every file in `modules/programs/`, `modules/home/`, and `modules/profiles/` to confirm
they export under `flake.modules.homeManager.*` (not flat `flake.modules.*`). Files to check:

| File | Expected export key |
|------|-------------------|
| `modules/home/vcs/git.nix` | `flake.modules.homeManager.git` |
| `modules/home/plasma.nix` | `flake.modules.homeManager.plasma` |
| `modules/home/vcs/jj.nix` | `flake.modules.homeManager.jj` |
| `modules/home/xcompose.nix` | `flake.modules.homeManager.xcompose` |
| `modules/home/uv.nix` | `flake.modules.homeManager.uv` |
| `modules/home/fonts/iosevka-carl.nix` | `flake.modules.homeManager.iosevka-carl` |
| `modules/programs/shell [ns]/bash.nix` | `flake.modules.homeManager.bash` |
| `modules/programs/shell [ns]/fish.nix` | `flake.modules.homeManager.fish` |
| `modules/programs/shell [ns]/zsh.nix` | `flake.modules.homeManager.zsh` |
| `modules/programs/terminal [ns]/zellij.nix` | `flake.modules.homeManager.zellij` |
| `modules/programs/shell [ns]/starship.nix` | `flake.modules.homeManager.starship` |
| `modules/profiles/personal-profile.nix` | `flake.modules.homeManager.personal-profile` |
| `modules/profiles/work-profile.nix` | `flake.modules.homeManager.work-profile` |

Any that still use a flat key need a one-line rename.

---

### Step 7 — Clean up `modules/home-modules-option.nix`

This file was a workaround to make `flake.modules` mergeable as a flat attrset. Once all modules
use the nested `flake.modules.homeManager.*` / `flake.modules.nixos.*` pattern, check whether
this option declaration is still necessary or conflicts with flake-parts' native handling of
`flake.*` options.

The dendritic example repo does not have an equivalent file — it relies on flake-parts' native
attrset merging. If `nix flake check` passes without it, delete it.

---

## Risk Notes

- **`carl-nixos` assembly has a live conflict today**: `modules/nixos.nix` and
  `modules/hosts/carl-nixos/flake-parts.nix` both set `flake.nixosConfigurations."carl-nixos"`.
  The last-imported one wins. Do Step 3 before deleting `modules/nixos.nix` to avoid a gap.

- **pkgs channels**: The `pkgs-channels` module (Step 1) must be added to `system-default`
  before `carl-packages` is imported through the new path, or it will fail with
  "pkgs-unstable is not in scope".

- **`systems.nix`**: Currently declares `flake.systems = ["x86_64-linux"]`. No change needed
  unless an aarch64 host is added.

- **`modules/factory/user [NSns]/user.nix`**: Used by `carl.nix`. Not changed in this plan.
  Verify the factory still produces correct NixOS/HM/system-manager modules after the namespace
  normalization in Step 6.

- **Secrets path**: `inputs.secrets` uses `path:./secrets` which is a non-flake path input.
  Moving files around doesn't affect this, but confirm `modules/nix/tools/secrets [NDnd]/`
  still has the right relative path after the restructure.

## Suggested Order

1. Step 1 (fix lib.nix) — prerequisite for everything else
2. Step 6 audit (namespace check) — cheap, catches surprises early
3. Step 2 (migrate homes/carl/) + Step 3 (fold hosts/carl-nixos/) in parallel
4. Step 4 (create carl-thinkpad-pw0j0jnb module)
5. Test: `nix flake check` and `nixos-rebuild build --flake .#carl-nixos`
6. Step 5 (delete old files)
7. Step 7 (clean up home-modules-option.nix)
