# Carl's Nix Configuration

Following the Dendritic pattern, mostly.

[Structured a bit like Doc-Steve's comprehensive example](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Comprehensive_Example#comprehensive-example).

The File Naming Conventions - Some directories have brackets. These brackets serve two purposes:

They indicate that a directory is the name of a feature, not just for organizational purposes. All feature .nix files are always located in a directory named after the feature.
In the brackets, the usage contexts of the feature are listed, categorized by letter: (N)ixOS and/or (S)ystem-manager. Small caps indicate usage in the Home-Manager context. Since not every Home-Manager Configuration works on both systems, "n" and "s" refer to usage for Home-Manager on the specific system. "D" and "d" could be used for systems with nix-darwin.

Currently three hosts: a personal NixOS desktop with home-manager as a module, a company-owned Ubuntu laptop with system-manager & home-manager standalone, and a Raspberry Pi Jellyfin server. No proprietary information shared, company secrets handled outside this repo.

## Raspberry Pi media server

`rpi-4b-mediaserver` mounts the Synology NAS's public SMB shares on demand:

| Share | Mount / Jellyfin library path |
| --- | --- |
| `//ds920/music` | `/mnt/nas/music` |
| `//ds920/photo` | `/mnt/nas/photo` |
| `//ds920/video` | `/mnt/nas/video` |

The mounts are guest-accessible and read-only, with local permissions for the
Jellyfin user/group. No NAS credentials are stored on the Pi. SMB2/3 is negotiated;
do not enable SMB1 to work around connection failures.

### Manual NAS and Tailscale setup

1. Enable SMB on the NAS and grant its guest account read/list access to `music`,
   `photo`, and `video`, including their contents. Prefer NAS-side read-only
   permissions as well. Client-side mount permissions cannot grant NAS access.
2. Install/enroll Tailscale on the NAS and make sure its MagicDNS machine name is
   `ds920`. Enable MagicDNS in the tailnet. Tailnet policy and the NAS firewall
   must permit the Pi to reach the NAS on TCP 445. Do not port-forward SMB from
   the public internet.
3. Deploy this configuration from an updated checkout on the Pi:

   ```sh
   sudo nixos-rebuild switch --flake /path/to/checkout#rpi-4b-mediaserver
   ```

4. Enroll the Pi manually, following the login URL and any device approval steps:

   ```sh
   sudo tailscale up --accept-dns=true
   ```

   Enrollment persists across reboots. If the NAS has a different MagicDNS name,
   override `mediaserver.nas.host` in the Pi's NixOS configuration.

The default `ds920` address uses Tailscale both on and off the NAS's LAN. Tailscale
can connect directly over the LAN when available; this is not fallback to ordinary
LAN SMB when Tailscale is disconnected. For LAN-only use, the router's DNS name
can be selected instead:

```nix
mediaserver.nas.host = "nas-0.mitchellwright.internal";
```

That router-local name needs additional DNS/routing setup to work off-LAN; merely
enrolling the Pi in Tailscale does not make it reachable. Share mappings are
configurable through `mediaserver.nas.shares`, with local mount names as keys and
SMB share names (not `/volume1/...` paths) as values.

### Verify mounts and configure Jellyfin

Check name resolution and connectivity on the Pi:

```sh
systemctl status tailscaled
tailscale status
getent ahostsv4 ds920
tailscale ping ds920
systemctl status mnt-nas-{music,photo,video}.automount

sudo -u jellyfin ls /mnt/nas/music
sudo -u jellyfin ls /mnt/nas/photo
sudo -u jellyfin ls /mnt/nas/video
findmnt -t cifs -o TARGET,SOURCE,FSTYPE,OPTIONS
```

Confirm the sources and `ro` mount option, and read a known media file as
`jellyfin`, not just its directory. `tailscale ping` alone does not verify SMB
permissions or TCP 445 access.

Open `http://<pi-address>:8096`, then use **Dashboard → Libraries → Add Media
Library** to add the paths above. Choose Music for the music share and the
appropriate photo/video content types for the others. If `video` mixes movies
and shows, point separate libraries at their respective subdirectories. Retarget
or remove any old `/mnt/nas/media` library entry.

Keep Jellyfin's database, cache, and transcoding storage on local writable disk.
Disable library features that save metadata, artwork, or subtitles beside media,
since the NAS mounts are read-only. Scan the libraries and test playback locally
and from an off-LAN Tailscale client. Tailnet policy must also allow that client
to reach the Pi's Jellyfin TCP port 8096.

### Availability and troubleshooting

Mounts are triggered by access (including Jellyfin scans), rather than required
at boot. Jellyfin can start without the NAS. Unused mounts can unmount after ten
minutes; active files may keep them busy. Initial mount attempts time out after
30 seconds. Once mounted, CIFS reconnect/error handling applies: that timeout does
not bound every subsequent file operation. Scanning and playback require the NAS
to be reachable.

Inspect failed mounts with:

```sh
journalctl -b -u tailscaled \
  -u mnt-nas-music.mount -u mnt-nas-photo.mount -u mnt-nas-video.mount
```

If an early access failed before tailnet enrollment or connectivity was ready,
reset failed units and retry directory access once the NAS resolves and responds:

```sh
sudo systemctl reset-failed mnt-nas-{music,photo,video}.mount
sudo -u jellyfin ls /mnt/nas/music
```

After deployment, also verify enrollment and mounts after a reboot, and test NAS
unavailability/recovery. Use console or LAN access for disruptive network tests;
do not disconnect Tailscale if it is the only management connection.
