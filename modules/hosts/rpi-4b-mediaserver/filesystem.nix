{...}: {
  # Guest, read-only SMB shares from the Synology DS920+ over Tailscale.
  # The root and firmware partitions come from the SD image module.
  flake.modules.nixos.rpi-4b-mediaserver-filesystem = {
    config,
    lib,
    ...
  }: {
    options.mediaserver.nas = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "nas-0";
        description = "Hostname or IP of the Synology NAS (MagicDNS by default)";
      };
      shares = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          music = "music";
          photo = "photo";
          video = "video";
        };
        description = "Mount name under /mnt/nas mapped to an SMB share name on the NAS";
      };
    };

    config = {
      fileSystems = lib.mapAttrs' (name: share:
        lib.nameValuePair "/mnt/nas/${name}" {
          device = "//${config.mediaserver.nas.host}/${share}";
          fsType = "cifs";
          options = [
            "ro"
            "guest"
            "username=guest"
            "iocharset=utf8"
            "uid=${config.services.jellyfin.user}"
            "gid=${config.services.jellyfin.group}"
            "file_mode=0440"
            "dir_mode=0550"
            "nounix" # use the local ownership and modes above
            "noatime"
            "_netdev"
            "nofail" # don't block boot if the NAS is down
            "soft"
            "x-systemd.automount" # mount on first access
            "x-systemd.idle-timeout=600"
            "x-systemd.mount-timeout=30s"
            "x-systemd.after=tailscaled.service"
          ];
        })
      config.mediaserver.nas.shares;
    };
  };
}
