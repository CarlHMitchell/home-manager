{config, ...}: {
  imports = [
    ./packages.nix
    ./desktop.nix
  ];

  work = {
    gitEmail = "carl.mitchell@gomotive.com";
    awsProfile = "keeptruckin";
    ktmrEnabled = true;
    jjPrePushCheckerScript = "${config.home.homeDirectory}/.config/home-manager/scripts/prek_ktmr.sh";
  };
}
