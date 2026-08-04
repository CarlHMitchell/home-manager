{...}: {
  flake.modules.homeManager.thinkpad-programs = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "github-work" = {
          HostName = "github.com";
          IdentityFile = "~/.ssh/id_ed25519";
        };
        "github-personal" = {
          HostName = "github.com";
          IdentityFile = "~/.ssh/gh_personal_ed25519";
        };
        "*" = {
          AddKeysToAgent = "yes";
          ForwardAgent = false;
          Compression = false;
          ServerAliveInterval = 0;
          ServerAliveCountMax = 3;
          HashKnownHosts = false;
          UserKnownHostsFile = "~/.ssh/known_hosts";
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
        };
      };
    };
  };
}
