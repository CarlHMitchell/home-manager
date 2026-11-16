# Tasks for this config

## Accelerate DxO PureRaw

Set up VFIO GPU passthrough for VM.

Set up Wine, Bottles, VM, etc.

## Set up BTRBak

Likewise Backblaze

## Figure out how to tell which modules get used in which outputs (repl?)

## Set up Impermanence, ramdisks

ensure /tmp is tmpfs

Set up impermanence for / & /home

tmpfs for /home

tmpfs for /

## Dendritic refactor

Still some old organization, essentially everything in `modules/home/` should be in `modules/programs/`, `modules/services/`, or `modules/system/settings/`

## Iosevka font

Need to build a module that rebuilds the custom binary, and updates flake.lock here with it. It's slow, and the result is big, so I don't want to rebuild it every time. Or maybe just pin the version in an override & abandon the prebuilt tarball would be better. Should be its own flake.

## JJ stuff

Auto `jj fix` if possible? Or use the new `jj run`.

# Secrets

SOPS-nix might be better. Very minimal needs here, most secrets are resident on Yubikeys, so not a lot for Nix to do.

## Structure

Some module naming is suboptimal IMO.

Make it a bit more obvious which configs are home-manager & which are nixos (and which are system-manager, etc.).

Had to remove `browser` from `system-desktop` default. Might want to restructure those types?

## rpi-4b-mediaplayer

NAS mount isn't working.

## local LLMs

Set up a local coding agent

Lemonade builds and installs, but nothing here configures GPU acceleration yet — the package pulls no ROCm/Vulkan inference backend (its buildInputs are just cli11, curl, mbedtls, libdrm, etc.); it fetches backends at runtime. Your hardware.graphics.extraPackages has only rocmPackages.clr.icd, which is OpenCL, not what llama.cpp-style ROCm backends use. You'll likely need rocmPackages.clr + rocblas/hipblas, your user in the render group, and possibly HSA_OVERRIDE_GFX_VERSION depending on the card. I'd want to know which GPU it is before recommending specifics — nix run .#... -- lemond and checking what it reports as detected devices is the quickest way to see what it's actually looking for.
