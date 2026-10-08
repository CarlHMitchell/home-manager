{...}: {
  flake.modules.homeManager.jj = {
    config,
    lib,
    pkgs,
    ...
  }: let
    gitEmail =
      if config.work.gitEmail != ""
      then config.work.gitEmail
      else config.personal.gitEmail;
    # Formatters are looked up on the caller's PATH first
    fallbackPath = lib.makeBinPath [pkgs.clang-tools pkgs.black pkgs.alejandra pkgs.uv];
    withFallback = pkgs.writeShellScript "jj-with-fallback-path" ''
      export PATH="$PATH:${fallbackPath}"
      exec "$@"
    '';
    formatAndRun = pkgs.writeShellApplication {
      name = "jj-format-and-run";
      text =
        ''
          export PATH="$PATH:${fallbackPath}"
        ''
        + builtins.readFile ./jj-format-and-run.sh;
    };
  in {
    home.packages = with pkgs; [
      meld
    ];
    home.file = {
      "${config.xdg.configHome}/jj/config.toml" = {
        force = true;
        text = ''
          [user]
          email = "${gitEmail}"
          name = "Carl Mitchell"

          [fsmonitor]
          backend = "watchman"
          watchman.register-snapshot-trigger = true

          [aliases]
          tug = ["bookmark", "move", "--from", "heads(::@- & bookmarks())", "--to", "@-"]
          # Format the selected commits (see jj-format-and-run.sh), then push/upload them.
          # Formatters come from PATH so project environments (direnv/nix) are respected.
          push = ["util", "exec", "--", "${formatAndRun}/bin/jj-format-and-run", "git", "push"]
          upload = ["util", "exec", "--", "${formatAndRun}/bin/jj-format-and-run", "gerrit", "upload"]
          log3 = ["log", "--limit", "3"]
          log5 = ["log", "--limit", "5"]
          showdead = ["log", "-r", 'dead()']
          abandead = ["abandon", 'dead()']
          fmt = ["util", "exec", "--", "bash", "-c", """
            set -eEuo pipefail
            rev="''${1:-@-}"
            jj show ''${rev} -s | rg "\\.[ch]$" | cut -d' ' -f 2 | xargs -r clang-format --style=file -i
            jj show ''${rev} -s | rg "\\.py$" | cut -d' ' -f 2 | xargs -r black
            jj show "''${rev}" -s | rg "\\.nix$" | cut -d' ' -f2 | xargs -r alejandra
          """, ""]

          # megamerge aliases
          # `jj stack <revset>` to include specific revs
          stack = ["rebase", "--after", "trunk()", "--before", "closest_merge(@)", "--revision"]
          # `jj stage` to include the whole stack after the megamerge
          stage = ["stack", "closest_merge(@).. ~ empty()"]
          # `jj restack` to rebase your changes onto `trunk()`
          restack = ["rebase", "--onto", "trunk()", "--source", "roots(trunk()..@) & mutable()"]
          # jj git fetch && jj new [main|master]
          gfm = ["util", "exec", "--", "bash", "-c", """
          set -eEuo pipefail
          jj git fetch
          if jj bookmark list main 2>&1 | rg --quiet "main:"; then
            jj new main
          elif jj bookmark list master 2>&1 | rg --quiet "master:"; then
            jj new master
          else
            echo "error, neither 'main' nor 'master' is a bookmark"
            return 1
          fi
          """, ""]
          # Check Commit Message
          ccm = ["util", "exec", "--", "bash", "-c", """
          COMMIT_ID="$(jj log -r "''${1:-"@-"}" --no-graph -T "self.commit_id()")"
          npx commitlint --verbose --from="''${COMMIT_ID}^" --to="''${COMMIT_ID}"
          """]

          # `jj mark [rev]` bookmarks rev (default @-) with the name from templates.git_push_bookmark
          mark = ["util", "exec", "--", "bash", "-c", """
          set -eEuo pipefail
          rev="''${1:-@-}"
          tmpl="$(jj config get templates.git_push_bookmark)"
          name="$(jj log -r "$rev" --no-graph -T "$tmpl")"
          jj bookmark create "$name" -r "$rev"
          """, ""]

          [templates]
          log_node = ${"'''"}
          if(self && !current_working_copy && !immutable && !conflict && in_branch(self),
            "◇",
            builtin_log_node
          )
          ${"'''"}
          git_push_bookmark = ${"'''"}slugify(description) ++ "-jj-" ++ change_id.short()${"'''"}

          [template-aliases]
          "in_branch(commit)" = 'commit.contained_in("immutable_heads()..bookmarks()")'
          "slugify(str)" = ${"'''"}
            truncate_end(
              65,
              str.first_line()
              .replace(" ","_")
              .replace("(","-")
              .replace(")","")
              .replace(regex:"[\x00-\x1f\x7f~^:?*\\[\\\\]", "")
              .replace(regex:"\\.\\.+", ".")
              .replace(regex:"/+","/")
              .remove_prefix("/")
              .remove_suffix("/")
              .remove_suffix(".")
              .replace(regex:"-{2,}", "-")
              .replace(regex:"\\.{2,}", ".")
            )
          ${"'''"}

          [git]
          sign-on-push = true
          private-commits = 'denylist()'

          [signing]
          backend = "ssh"
          behavior = "own"
          key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub"

          [signing.backends]
          ssh.allowed-signers = "${config.home.homeDirectory}/.ssh/allowed_signers"
          ssh.program = "ssh-keygen"

          [ui]
          dif-formatter = ["difft", "--color=always", "$left", "$right"]
          show-cryptographic-signatures = true
          # diff-editor = "meld-3"

          [revset-aliases]
          # trunk() by default resolves to the latest 'main'/'master' remote bookmark. May
          # require customization for repos like nixpkgs.
          'trunk()' = 'latest((present(main) | present(master)) & remote_bookmarks())'
          'dead()' = '(empty() ~ merges()) & description(exact:"") & mine() & ~ root() & ~ bookmarks() & ~ tags() & ~ @'
          'nodesc()' = 'description(exact:"") & ~ merges() & mine() & ~ root() & ~ bookmarks() & ~ tags() & visible_heads() & ~ @'
          'my_work()' = 'mine() & visible_heads() & ~root() & ~remote_bookmarks() & ~tags()'

          # Private and WIP commits that should never be pushed anywhere. Often part of
          # work-in-progress merge stacks.
          'wip()' = 'description(glob:"wip:*")'
          'private()' = 'description(glob:"private:*")'
          'goodsubject()' = 'subject(regex:"^(?<COMMIT_TYPE>feat|fix|perf|revert|docs|style|refactor|test|build|ci|chore)(?<SCOPE>\\((?<JIRA_BOARD>[A-Z]{3,})-(?<TICKET_NUMBER>[0-9]+)\\))?: (?<DESCRIPTION>[a-z0-9][a-zA-Z0-9 \\-_/().,#+]*[a-zA-Z0-9\\-_/(),#+])$")'
          'denylist()' = 'wip() | private() | ~ goodsubject()'
          # Returns the closest merge commit to `to`
          "closest_merge(to)" = "heads(::to & merges())"
          'via_commits()' = 'subject(regex:"^(?<COMMIT_TYPE>feat|fix|perf|revert|docs|style|refactor|test|build|ci|chore)(?<SCOPE>\\(VIA-(?<TICKET_NUMBER>[0-9]+)\\))?: (?<DESCRIPTION>[a-z0-9][a-zA-Z0-9 \\-_/().,#+]*[a-zA-Z0-9\\-_/(),#+])$")'

          [fix.tools.1-clang-format]
          command = ["${withFallback}", "clang-format", "--style=file", "--assume-filename=$path"]
          patterns = ["glob:'**/*.c'",
                      "glob:'**/*.h'"]

          [fix.tools.2-black]
          command = ["${withFallback}", "black", "-", "--stdin-filename=$path"]
          patterns = ["glob:'**/*.py'"]

          [fix.tools.3-pre-commit]
          command = ["${withFallback}", "uvx", "--with", "pre-commit", "jj-pre-push", "check"]
          patterns = ["glob:'*'"]

          [fix.tools.4-alejandra]
          command = ["${withFallback}", "alejandra"]
          patterns = ["glob:'**/*.nix'"]

          # Broken
          # [fix.tools.5-commitlint]
          # command = ["${config.home.homeDirectory}/.config/home-manager/scripts/commitlintfix.sh"]
          # patterns = ["glob:'*'"]
        '';
      };
    };
  };
}
