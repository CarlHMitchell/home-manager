{...}: {
  # Network mounts from the Synology DS920+ (NFS must be enabled in DSM, with
  # NFS permissions on the shared folder allowing this host's IP).
  # The root and firmware partitions come from the SD image module.
  flake.modules.nixos.rpi-4b-mediaserver-filesystem = {
    config,
    lib,
    ...
  }: {
    options.mediaserver.nas = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "ds920.local";
        description = "Hostname or IP of the Synology NAS";
      };
      shares = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {media = "/volume1/media";};
        description = "Mount name under /mnt/nas mapped to the exported path on the NAS";
      };
    };

    config = {
      fileSystems = lib.mapAttrs' (name: exportPath:
        lib.nameValuePair "/mnt/nas/${name}" {
          device = "${config.mediaserver.nas.host}:${exportPath}";
          fsType = "nfs";
          options = [
            "nfsvers=4.1"
            "ro"
            "noatime"
            "_netdev"
            "nofail" # don't block boot if the NAS is down
            "x-systemd.automount" # mount on first access
            "x-systemd.idle-timeout=600"
            "x-systemd.mount-timeout=30"
          ];
        })
      config.mediaserver.nas.shares;
    };
  };
}
