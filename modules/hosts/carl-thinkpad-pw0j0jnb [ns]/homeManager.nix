{self, ...}: {
  flake.modules.homeManager."carl@carl-thinkpad-pw0j0jnb" = {
    config,
    lib,
    ...
  }: {
    imports = with self.modules.homeManager; [
      carl-base
      thinkpad-packages
      slack-sandboxed
      thinkpad-desktop
      node
      thinkpad-programs
      hister
      memory-pressure
    ];

    home.file.".ssh/authorized_keys".text =
      lib.concatMapStrings (key: key + "\n") config.systemConstants.sshAuthorizedKeys;

    work = {
      gitEmail = "carl.mitchell@gomotive.com";
      awsProfile = "keeptruckin";
      ktmrEnabled = true;
      jjPrePushCheckerScript = "${config.home.homeDirectory}/.config/home-manager/scripts/prek_ktmr.sh";
    };
  };
}
