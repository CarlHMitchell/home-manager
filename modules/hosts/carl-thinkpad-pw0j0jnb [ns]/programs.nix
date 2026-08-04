{...}: {
  flake.modules.homeManager.ssh = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.ssh = {
      enable = true;
      settings = {
        "github-work" = {
          HostName = "github.com";
          IdentityFile = "~/.ssh/id_ed25519";
        };
        "github-personal" = {
          HostName = "github.com";
          IdentityFile = "~/.ssh/gh_personal_ed25519";
        };
      };
    };
  };
}
