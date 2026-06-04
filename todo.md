# Tasks for this config

## Migrate data & programs from Windows

Set up Wine, Bottles, etc.

Back up data to NAS.

Wipe E: SSD, add to btrfs pool. Set Steam to use it.

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
