{ config, lib, pkgs, ... }:
{
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

    initContent = ''
      if command -v starship >/dev/null; then
        eval "$(starship init zsh)"
      else
        echo "Starship not installed"
      fi
      if command -v direnv >/dev/null; then
        eval "$(direnv hook zsh)"
      else
        echo "Direnv not installed"
      fi
      if command -v pay-respects >/dev/null; then
        eval "$(pay-respects zsh --alias)"
      else
        echo "pay-respects not installed"
      fi
      export KTMR_DIRENV_SKIP_NIX_VERSION_CHECK="iknowwhatimdoing"
      export AWS_PROFILE="keeptruckin"
      if [ -f "/home/carl/.config/ktmr/load.sh" ]; then
        source "/home/carl/.config/ktmr/load.sh"
      fi
      ## Keybindings section
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
      via_changelog() { git log "--pretty=oneline" "--abbrev-commit" "$(git tag | grep "via_app-$1")..HEAD" "/home/carl/code/KeepTruckin/kt/src/embedded/via" && git log "--pretty=oneline" "--abbrev-commit" "$(git tag | grep "via_app-$1")..HEAD" "/home/carl/code/KeepTruckin/kt/src/proto/embedded/via" }
      space() { btrfs fi df $1 && btrfs fi usage $1 }
      mkcd() { mkdir -p $1 && cd $1 }
      viac() { minicom -c on -O timestamp=extended -C ~/tmp/via_console_$(date -Is).log -D "/dev/ttyUSB$1" }
      vg5c() { minicom -c on -O timestamp=extended -C ~/tmp/vg5_console_$(date -Is).log -D "/dev/ttyACM$1" }
      title() { echo $'\033]30;'"$1"; }
      canup() { sudo ip link set $1 up type can bitrate $2; }
      candetails() { sudo ip -d link show $1; }
      candown() { sudo ip link set $1 down; }
      canreset() { sudo ip link set $1 down && sudo ip link set $1 up type can bitrate $2; }
      aws_id() { openssl x509 -in "$1" -outform DER | sha256sum; }
      hex() { hexdump -e '8/1 \"0x%02X, \"' $1; }
    '';

    shellAliases = rec {
      ls = "eza --color=auto --group-directories-first --time-style long-iso";
      la = "${ls} --all";
      ll = "${ls} --all --long --header --group";
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
        sudo nix-collect-garbage -d &&
        docker system prune --volumes &&
        sudo btrfs balance start -dusage=10 -musage=10
      '';
      emb = "cd ~/code/KeepTruckin/kt/src/embedded";
      via = "cd ~/code/KeepTruckin/kt/src/embedded/via";
      ktpc = "$KTMR_PATH/.git/hooks/pre-commit";
    };
  };
}
