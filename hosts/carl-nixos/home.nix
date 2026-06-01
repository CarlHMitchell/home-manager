# carl-nixos specific home-manager config.
# Most config is inherited from homes/carl/. Add host-specific overrides here.
{pkgs, ...}: {
  home.packages = with pkgs; [
    kdePackages.kate
  ];

  personal.gitEmail = ""; # TODO: set personal email
}
