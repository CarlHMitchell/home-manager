{...}: {
  flake.modules.homeManager.zsh = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
        ];
      };
      dotDir = "${config.xdg.configHome}/zsh";

      initContent = ''
        if command -v direnv >/dev/null; then
          eval "$(direnv hook zsh)"
        else
          echo "Direnv not installed"
        fi
        if command -v mise >/dev/null; then
          eval "$(mise activate zsh)"
        else
          echo "mise not installed"
        fi
        if command -v pay-respects >/dev/null; then
          eval "$(pay-respects zsh --alias)"
        else
          echo "pay-respects not installed"
        fi
        ${lib.optionalString config.work.ktmrEnabled ''
          export KTMR_DIRENV_SKIP_NIX_VERSION_CHECK="iknowwhatimdoing"
          if [ -f "${config.home.homeDirectory}/.config/ktmr/load.sh" ]; then
            source "${config.home.homeDirectory}/.config/ktmr/load.sh"
          fi
        ''}
        ${lib.optionalString (config.work.awsProfile != null) ''
          export AWS_PROFILE="${config.work.awsProfile}"
        ''}
        export PATH="$PATH:${config.home.homeDirectory}/bin:${config.home.homeDirectory}/.local/bin:${config.home.homeDirectory}/.cargo/bin"
        if ! pgrep -u "$USER" ssh-agent >/dev/null; then
          eval "$(ssh-agent -s)"
        fi
        ## ==================== Keybindings ====================================
        bindkey -e
        bindkey '^[[7~' beginning-of-line                               # Home key
        bindkey '^[[H' beginning-of-line                                # Home key
        if [[ "''${terminfo[khome]}" != "" ]]; then
        bindkey "''${terminfo[khome]}" beginning-of-line                # [Home] - Go to beginning of line
        fi
        bindkey '^[[8~' end-of-line                                     # End key
        bindkey '^[[F' end-of-line                                     # End key
        if [[ "''${terminfo[kend]}" != "" ]]; then
        bindkey "''${terminfo[kend]}" end-of-line                       # [End] - Go to end of line
        fi
        bindkey '^[[2~' overwrite-mode                                  # Insert key
        bindkey '^[[3~' delete-char                                     # Delete key
        bindkey '^[[C'  forward-char                                    # Right key
        bindkey '^[[D'  backward-char                                   # Left key
        bindkey '^[[5~' history-beginning-search-backward               # Page up key
        bindkey '^[[6~' history-beginning-search-forward                # Page down key
        # Navigate words with ctrl+arrow keys
        bindkey '^[Oc' forward-word                                     #
        bindkey '^[Od' backward-word                                    #
        bindkey '^[[1;5D' backward-word                                 #
        bindkey '^[[1;5C' forward-word                                  #
        bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
        ## ================= FUNCTIONS =========================================
        ${lib.optionalString config.work.ktmrEnabled ''
          via_changelog() { git log "--pretty=oneline" "--abbrev-commit" "$(git tag | grep "via_app-$1")..HEAD" "${config.home.homeDirectory}/code/KeepTruckin/kt/src/embedded/via" && git log "--pretty=oneline" "--abbrev-commit" "$(git tag | grep "via_app-$1")..HEAD" "${config.home.homeDirectory}/code/KeepTruckin/kt/src/proto/embedded/via" }
          viac() { minicom -c on -O timestamp=extended -C ~/tmp/via_console_$(date -Is).log -D "/dev/ttyUSB$1" }
          vg5c() { minicom -c on -O timestamp=extended -C ~/tmp/vg5_console_$(date -Is).log -D "/dev/ttyACM$1" }
        ''}
        space() { btrfs fi df $1 && btrfs fi usage $1 }
        mkcd() { mkdir -p $1 && cd $1 }
        title() { echo $'\033]30;'"$1"; }
        canup() { sudo ip link set $1 up type can bitrate $2; }
        candetails() { sudo ip -d link show $1; }
        candown() { sudo ip link set $1 down; }
        canreset() { sudo ip link set $1 down && sudo ip link set $1 up type can bitrate $2; }
        aws_id() { openssl x509 -in "$1" -outform DER | sha256sum; }
        hex() { hexdump -e '8/1 \"0x%02X, \"' $1; }
        set-konsole-tab-title-type ()
        {
            local _title="$1"
            local _type="''${2:-0}"
            [[ -z "''${_title}" ]]               && return 1
            [[ -z "''${KONSOLE_DBUS_SERVICE}" ]] && return 1
            [[ -z "''${KONSOLE_DBUS_SESSION}" ]] && return 1
            qdbus >/dev/null "''${KONSOLE_DBUS_SERVICE}" "''${KONSOLE_DBUS_SESSION}" setTabTitleFormat "''${_type}" "''${_title}"
        }
        set-konsole-tab-title ()
        {
            set-konsole-tab-title-type "$1" && set-konsole-tab-title-type "$1" 1
        }
        pwd-konsole-title ()
        {
          set-konsole-tab-title "''$(pwd | awk -F/ '{print $NF}')"
        }
        cdt () { cd "$1" && pwd-konsole-title }
        pushdt () { pushd "$1" && pwd-konsole-title }
        popdt () { popd && pwd-konsole-title }
        ${lib.optionalString config.work.ktmrEnabled ''
          fixtemp ()
          {
            local tempdir="''$(nix-shell --help 2>&1 >/dev/null | cut -d ' ' -f 4 | cut -b 2- | cut -d '/' -f -3)"
            if [ -n "''${tempdir}" ] && [ "or" != "''${tempdir}" ]; then
              mkdir -p "''${tempdir}"
            fi
          }
          fixtemp
        ''}
        lfs_depop () { git read-tree HEAD && GIT_LFS_SKIP_SMUDGE=1 git checkout -f HEAD }
        clang-format-changed () { jj diff --summary -r @ | awk '{print $2}' | rg --type=c --color=never '.*' | xargs --max-procs=4 -I {} clang-format --style=file -i {} }
        sshnas () { ssh -i ~/.ssh/id_ed25519 -p 49222 nas-0-admin@192.168.50.201 }
        check_commit_message() {
          COMMIT_ID="$(jj log -r "''${1:-"@-"}" --no-graph -T "self.commit_id()")"
          npx commitlint --verbose --from="''${COMMIT_ID}^" --to="''${COMMIT_ID}"
        }
      '';

      shellAliases =
        rec {
          ls = "eza --color=auto --group-directories-first --time-style long-iso";
          la = "${ls} --all";
          ll = "${ls} --all --long --header --group";
          cd = "cdt";
          pushd = "pushdtitle";
          popd = "popdtitle";
          generations = ''
            echo "boot generations" &&
            sudo nix-env -p /nix/var/nix/profiles/system/ --list-generations &&
            echo "system generations" &&
            nix-env --list-generations
          '';
          calc = "orpie";
          gitgc = ''
            git prune &&
            rm "$(git rev-parse --show-toplevel)/.git/gc.log" &&
            git gc
          '';
          btrfsbalance = ''
            for i in 0 5 10 15 20 25 30 40 50 60 70 80 90 100; do
              echo "btrfs balance: running with $i% on /"
              sudo btrfs balance start -dusage=$i -musage=$i /;
            done
          '';
          spacesaver = ''
            sudo rm /nix/var/nix/gcroots/auto/* &&
            sudo nix-collect-garbage -d &&
            docker system prune --volumes &&
            btrfsbalance /
          '';
          spacefast = ''
            sudo rm /nix/var/nix/gcroots/auto/* &&
            nix-collect-garbage -d &&
            docker system prune --volumes &&
            sudo btrfs balance start -dusage=10 -musage=10
          '';
          jjfmt = "jj st | rg '[M|A] .*\\.[c|h]' | cut -b 3- | xargs clang-format -i --style=file --verbose";
        }
        // lib.optionalAttrs config.work.ktmrEnabled {
          emb = "cd ~/code/KeepTruckin/kt/src/embedded";
          via = "cd ~/code/KeepTruckin/kt/src/embedded/via";
          ktpc = "$KTMR_PATH/.git/hooks/pre-commit";
        };
    };
  };
}
