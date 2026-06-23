let
  carl-carl-nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyOt0kfpxsWk0MUouYfYsucWSLOm45P526SU0d40kGj";
  carl-carl-thinkpad-pw0j0jnb = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6uxGJ1DLnFasXcRQYp7tM7UL0vVfV+5Fg7IKSxGfuu carl@carl-thinkpad-pw0j0jnb";
  users = [carl-carl-nixos carl-carl-thinkpad-pw0j0jnb];

  carl-nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwfp63tnl9rUnkYdxPYAz4q3OxPlgTgNkWfUR8U0w7X";
  carl-thinkpad-pw0j0jnb = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM4QGIaXRYtnMsva0t9MqoZlYlofQYhL6BSke9UneER7 root@carl-thinkpad-pw0j0jnb";
  systems = [carl-nixos carl-thinkpad-pw0j0jnb];
in {
  "example_secret.age".publicKeys = [carl-carl-nixos carl-nixos];
  "thinkpad_ssh_key.age".publicKeys = [carl-thinkpad-pw0j0jnb];
}
