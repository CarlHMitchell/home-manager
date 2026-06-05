# Tasks for this config

## Migrate data & programs from Windows

Set up Wine, Bottles, etc.

# Set up BTRBak

## Set up Impermanence, ramdisks

ensure /tmp is tmpfs

Set up impermanence for / & /home

tmpfs for /home

tmpfs for /

## Dendritic refactor

Understand it better. I vibed it, and I don't like that. Learned a few new things in the process.

Write down things I learned.

## Iosevka font

Need to build a module that rebuilds the custom binary, and updates flake.lock here with it. It's slow, and the result is big, so I don't want to rebuild it every time. Or maybe just pin the version in an override & abandon the prebuilt tarball would be better.

## JJ stuff

Auto jj fix if possible?

Add alejandra for .nix files

## Music player

https://deadbeef.sourceforge.io/ or https://fooyin.org/ or something

## nix repl

:lf <path> to load a flake

:p <item> to evaluate (print) item eagerly

<item> to evaluate (print) item lazily

:b <package> to build a package

:sh <shell> to build & enter a shell

nixos-rebuild repl --flake <path> to get a repl with the flake loaded, and use `:r` to refresh when changes are made

`nix-inspect --expr 'builtins.getFlake "<path>"' for a nice browser

## Structure desired

Get rid of personalPackages & personalServices, etc. Only the options used in scripts should be kept, to prevent excessive duplication.

Some module naming is suboptimal IMO.

Make it a bit more obvious which configs are home-manager & which are nixos (and which are system-manager, etc.).

Had to remove `browser` from `system-desktop` default. Might want to restructure those types?

system-manager isn't getting used. It'd be nice to fix that.

❯ tree
.
├── binaries
│   └── IosevkaCarl.tar.zstd
├── flake.lock
├── flake.nix
├── lessons.md
├── mise.toml
├── modules
│   ├── factory # Reusable builder modules
│   │   └── user [NSns]
│   │       └── user.nix # config, sets up user defaults when passed in a username & isAdmin
│   ├── home # Should be home-manager only modules. flake.modules.homeManager.<aspect>
│   │   ├── fonts
│   │   │   ├── flake-parts.nix
│   │   │   └── iosevka-carl.nix # Hardcoded prebuild, for now
│   │   ├── gaming # future Steam & similar config
│   │   ├── plasma.nix # Plasma-manager config, 
│   │   ├── uv.nix
│   │   ├── vcs
│   │   │   ├── git.nix
│   │   │   └── jj.nix
│   │   └── xcompose.nix
│   ├── hosts # each computer's config
│   │   ├── carl-nixos # flake.modules.nixos.carl-nixos for all these files.
│   │   │   ├── configuration.nix
│   │   │   ├── filesystem.nix
│   │   │   ├── flake-parts.nix
│   │   │   ├── hardware.nix
│   │   │   ├── programs.nix
│   │   │   ├── services
│   │   │   ├── services.nix
│   │   │   └── users
│   │   │       └── carl.nix
│   │   └── carl-thinkpad-pw0j0jnb [ns] # flake.modules.homeManager
│   │       ├── desktop.nix
│   │       ├── flake-parts.nix
│   │       ├── homeManager.nix
│   │       ├── packages.nix # home-manager packages
│   │       └── systemManager.nix # flake.modules.systemManager?
│   ├── nix # 
│   │   ├── flake-parts # some helpers for flake-parts
│   │   │   ├── dendritic-tools.nix
│   │   │   ├── factory.nix
│   │   │   └── lib.nix
│   │   ├── system-manager.nix # probably the wrong place
│   │   └── tools # shared-use tools for nix config
│   │       ├── home-manager [NS]
│   │       │   ├── flake-parts.nix
│   │       │   └── home-manager.nix
│   │       ├── impermanence [N]
│   │       │   ├── flake-parts.nix
│   │       │   ├── impermanence.nix
│   │       │   └── minimum.nix
│   │       ├── pkgs-by-name [G]
│   │       │   ├── flake-parts.nix
│   │       │   └── pkgs-by-name.nix
│   │       ├── pkgs-channels [n]
│   │       │   ├── flake-parts.nix
│   │       │   └── pkgs-channels.nix
│   │       ├── plasma-manager [n]
│   │       │   └── flake-parts.nix
│   │       └── secrets [NDnd]
│   │           ├── flake-parts.nix
│   │           └── secrets.nix
│   ├── profiles # config-creation modules for personal & work use, e.g. for private shell aliases
│   │   ├── personal-profile.nix
│   │   └── work-profile.nix
│   ├── programs # program modules
│   │   ├── browser [ns]
│   │   │   ├── browser.nix
│   │   │   └── impermanence.nix
│   │   ├── cli-tools [NS]
│   │   │   ├── generic.nix
│   │   │   └── nixos.nix
│   │   ├── shell [ns]
│   │   │   ├── bash.nix
│   │   │   ├── fish.nix
│   │   │   ├── impermanence.nix
│   │   │   ├── shell.nix
│   │   │   ├── starship.nix
│   │   │   └── zsh.nix
│   │   └── terminal [ns]
│   │       └── zellij.nix
│   ├── services # Service modules
│   │   ├── iperf [N]
│   │   │   └── iperf.nix
│   │   ├── printing [N]
│   │   │   └── printing.nix
│   │   ├── ssh [NS]
│   │   │   └── ssh.nix
│   │   └── syncthing [N]
│   │       └── syncthing.nix
│   ├── system
│   │   ├── settings
│   │   │   ├── bluetooth [N]
│   │   │   │   ├── bluetooth.nix
│   │   │   │   └── impermanence.nix
│   │   │   ├── firmware [N]
│   │   │   │   └── firmware.nix
│   │   │   ├── network
│   │   │   │   └── subnet-A [networkInterfaces]
│   │   │   │       └── subnet-A.nix
│   │   │   ├── systemConstants [NSns]
│   │   │   │   └── systemConstants.nix
│   │   │   └── systemd-boot [N]
│   │   │       └── systemd-boot.nix
│   │   └── system types
│   │       ├── 1 - system-minimal [NSns]
│   │       │   ├── homeManager
│   │       │   │   └── homeManager-minimal.nix
│   │       │   ├── nixos
│   │       │   │   ├── flake-parts.nix
│   │       │   │   └── nixos-minimal.nix
│   │       │   └── system-manager
│   │       │       ├── flake-parts.nix
│   │       │       └── system-manager-minimal.nix
│   │       ├── 2 - system-default [NSns]
│   │       │   └── system-default.nix
│   │       ├── 3 - system-cli [NSns]
│   │       │   └── system-cli.nix
│   │       └── 4 - system-desktop [NSns]
│   │           └── system-desktop.nix
│   ├── systems.nix
│   └── users
│       └── carl [Nns]
│           ├── carl.nix # Base user config, shared among all "carl" users. WIP.
│           ├── flake-parts.nix
│           └── home
│               ├── packages.nix
│               ├── programs.nix
│               └── services.nix
├── packages
│   └── cowsay
│       └── package.nix
├── README.md
├── refactor_plan.md
├── refactor_plan_part_2.md
├── scripts
│   ├── commit_with_checks.sh
│   ├── conventional_commit_check.sh
│   └── prek_ktmr.sh
├── secrets
└── todo.md
