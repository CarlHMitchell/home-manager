# carl-nixos specific home-manager config.
# Most config is inherited from homes/carl/. Add host-specific overrides here.
{config, pkgs, ...}: {

  personal = {
   gitEmail = "github@eufalconimorph.com";
   programs = true;
   services = true;
   packages = true;
  };
}
