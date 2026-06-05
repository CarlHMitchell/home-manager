{self, ...}: {
  flake.modules.homeManager."carl@carl-thinkpad-pw0j0jnb" = {config, ...}: {
    imports = with self.modules.homeManager; [
      carl-base
      thinkpad-packages
      thinkpad-desktop
    ];

    work = {
      gitEmail = "carl.mitchell@gomotive.com";
      awsProfile = "keeptruckin";
      ktmrEnabled = true;
      jjPrePushCheckerScript = "${config.home.homeDirectory}/.config/home-manager/scripts/prek_ktmr.sh";
    };
  };
}
