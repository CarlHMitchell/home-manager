# Slack (Electron) needs its chrome-sandbox to be setuid root. After each
# update the new store path has the wrong mode, so fix it on every activation.
# Needs sudo.
{...}: {
  flake.modules.homeManager.slack-sandboxed = {
    lib,
    pkgs,
    ...
  }: let
    sandbox = "${pkgs.slack}/lib/slack/chrome-sandbox";
  in {
    home.activation.slackChromeSandbox = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ "$(stat -c '%U %a' ${sandbox})" != "root 4755" ]; then
        run /usr/bin/sudo chown root:root ${sandbox}
        run /usr/bin/sudo chmod 4755 ${sandbox}
      fi
    '';
  };
}
