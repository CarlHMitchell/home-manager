{...}: {
  # Plasma/desktop integration workarounds.
  # Icons and .desktop files don't appear correctly in Plasma without these hooks.
  flake.modules.homeManager.thinkpad-desktop = {
    config,
    pkgs,
    lib,
    ...
  }: {
    # Never DPMS off the internal panel: the eDP link fails to retrain on
    # wake (i915 "Timed out waiting for DP idle patterns" / DDI BUF A stuck),
    # leaving the built-in screen permanently black until reboot.
    programs.plasma.powerdevil = {
      AC.turnOffDisplay.idleTimeout = "never";
      battery.turnOffDisplay.idleTimeout = "never";
    };

    # Populate the desktop file cache on login so Plasma can find app icons.
    programs.bash.profileExtra = lib.mkAfter ''
      rm -rf ${config.home.homeDirectory}/.local/share/applications/home-manager
      rm -rf ${config.home.homeDirectory}/.icons/nix-icons
      ls ${config.home.homeDirectory}/.nix-profile/share/applications/*.desktop > ${config.home.homeDirectory}/.cache/current_desktop_files.txt
    '';

    home.activation = {
      make-zsh-default-shell = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # if zsh is not the current shell
        PATH="/usr/bin:/bin:$PATH"
        ZSH_PATH="/home/${user}/.nix-profile/bin/zsh"
        if [[ $(getent passwd ${user}) != *"$ZSH_PATH" ]]; then
          echo "setting zsh as default shell (using chsh). password might be necessay."
          if ! grep -q $ZSH_PATH /etc/shells; then
            echo "adding zsh to /etc/shells"
            run echo "$ZSH_PATH" | sudo tee -a /etc/shells
          fi
          echo "running chsh to make zsh the default shell"
          run chsh -s $ZSH_PATH ${user}
          echo "zsh is now set as default shell !"
        fi
      '';
      linkDesktopApplications = {
        after = ["writeBoundary" "createXdgUserDirectories"];
        before = [];
        data = ''
          rm -rf ${config.home.homeDirectory}/.local/share/applications/home-manager
          rm -rf ${config.home.homeDirectory}/.icons/nix-icons
          mkdir -p ${config.home.homeDirectory}/.local/share/applications/home-manager
          mkdir -p ${config.home.homeDirectory}/.icons
          ln -sf ${config.home.homeDirectory}/.nix-profile/share/icons ${config.home.homeDirectory}/.icons/nix-icons

          # Check if the cached desktop files list exists
          if [ -f ${config.home.homeDirectory}/.cache/current_desktop_files.txt ]; then
            current_files=$(cat ${config.home.homeDirectory}/.cache/current_desktop_files.txt)
          else
            current_files=""
          fi

          # Symlink new desktop entries
          for desktop_file in ${config.home.homeDirectory}/.nix-profile/share/applications/*.desktop; do
            if ! echo "$current_files" | grep -q "$(basename $desktop_file)"; then
              ln -sf "$desktop_file" ${config.home.homeDirectory}/.local/share/applications/home-manager/$(basename $desktop_file)
            fi
          done

          # Update desktop database
          ${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.home.homeDirectory}/.local/share/applications
        '';
      };
    };
  };
}
