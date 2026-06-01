{pkgs, ...}: {
  home.packages = with pkgs; [
    # Work comms
    slack

    # Embedded hardware tools
    gcc-arm-embedded
    stlink
    openocd
    segger-ozone
    saleae-logic-2
    dfu-util
    mcumgr-client
    nanovna-saver
    can-utils
    nanopb
    protoscope

    # PCB design
    kicad

    # Motive-specific dev tools
    protolint
    jira-cli-go
    gerrit
    nuget

    # KVM software (workstation-specific peripherals)
    input-leap

    # Local Kubernetes
    k3s
  ];
}
