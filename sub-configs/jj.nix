{
  config,
  lib,
  pkgs,
  ...
}: {

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = "carl.mitchell@gomotive.com";
        name = "Carl Mitchell";
        signing.behavior = "own";
        signing.backend = "ssh";
        signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6uxGJ1DLnFasXcRQYp7tM7UL0vVfV+5Fg7IKSxGfuu carl@carl-thinkpad-pw0j0jnb";
        git = {
          sign-on-push = true;
        };
        ui = {
          dif-formatter = ["difft" "--color=always" "$left" "$right"];
          show-cryptographic-signatures = true; # May be slow
        };
        aliases = {
          ps = (builtins.readFile ./jj_ps.toml);
        };
      };
    };
  };
}
