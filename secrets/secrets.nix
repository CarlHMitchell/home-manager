let
  carl-carl-nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyOt0kfpxsWk0MUouYfYsucWSLOm45P526SU0d40kGj";
  users = [carl-carl-nixos];

  carl-nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwfp63tnl9rUnkYdxPYAz4q3OxPlgTgNkWfUR8U0w7X";
  systems = [carl-nixos];
in {
  "example_secret.age".publicKeys = [carl-carl-nixos carl-nixos];
}
