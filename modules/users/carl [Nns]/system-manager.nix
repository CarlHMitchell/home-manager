# The carl account on Ubuntu hosts managed by system-manager.
#
# system-manager runs userborn on every activation AND every boot. userborn
# manages every user and group declared in the profile: any group declared with
# fewer members than /etc/group has (system-manager declares the stock Ubuntu
# groups -- sudo, adm, cdrom, dialout, ... -- with `members = []` by default) gets
# its membership overwritten, and a user that was in the previous profile but is
# missing from the new one gets disabled ("!*" in /etc/shadow).
#
# So EVERY system-manager profile for a host where carl logs in must import this
# module, or activating it will lock carl out of sudo and password login.
{...}: {
  flake.modules.systemManager.carl-user = {...}: {
    users.groups.carl.gid = 1000;

    users.users.carl = {
      isNormalUser = true;
      uid = 1000;
      group = "carl";
      home = "/home/carl";
      # Ubuntu's own bash, not a nix path under /run (tmpfs, only populated once
      # system-manager's path service has run).
      shell = "/bin/bash";
      # Only applied when userborn *creates* the user. Using hashedPassword here
      # would overwrite the live password on every boot (undoing `passwd`).
      initialHashedPassword = "$y$j9T$VzoR5TnMIvmGCWcmNIMSP.$y1j94mYHM3m7ih4thLTtrRWRA1VVZfaErcZua7im3I.";
      # Every group declared by system-manager has its member list overwritten,
      # so anything carl needs must be listed here. Compare against a pre-switch
      # `id` if something else (video, render, input, kvm, audio, ...) is missing.
      extraGroups = [
        "adm"
        "cdrom"
        "sudo"
        "dialout"
        "systemd-journal"
        "dip"
        "plugdev"
        "lpadmin"
        "sambashare"
        "docker"
      ];
    };
  };
}
