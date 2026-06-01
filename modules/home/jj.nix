{...}: {
  flake.homeModules.jj = {config, lib, ...}: {
    home.file = {
      "${config.xdg.configHome}/jj/config.toml" = {
        force = true;
        text = ''
          [user]
          email = "${config.work.gitEmail}"
          name = "Carl Mitchell"

          [fsmonitor]
          backend = "watchman"
          watchman.register-snapshot-trigger = true

          [aliases]
          tug = ["bookmark", "move", "--from", "heads(::@- & bookmarks())", "--to", "@-"]
          # https://github.com/acarapetis/jj-pre-push
          push = ["util", "exec", "--", "uvx", "--with", "pre-commit", "jj-pre-push", "--checker", "prek", "push"]
          check = ["util", "exec", "--", "uvx", "--with", "pre-commit", "jj-pre-push", "--checker", "prek", "check"]
          ${lib.optionalString (config.work.jjPrePushCheckerScript != null) ''
          pushk = ["util", "exec", "--", "uvx", "--with", "pre-commit", "jj-pre-push", "--checker", "${config.work.jjPrePushCheckerScript}", "push"]
          checkk = ["util", "exec", "--", "uvx", "--with", "pre-commit", "jj-pre-push", "--checker", "${config.work.jjPrePushCheckerScript}", "check"]
          ''}
          desc = ["util", "exec", "--", "bash", "${config.home.homeDirectory}/.config/home-manager/scripts/conventional_commit_check.sh"]
          com = ["util", "exec", "--", "bash", "${config.home.homeDirectory}/.config/home-manager/scripts/commit_with_checks.sh"]
          log3 = ["log", "--limit", "3"]
          log5 = ["log", "--limit", "5"]
          showdead = ["log", "-r", 'dead()']
          abandead = ["abandon", 'dead()']

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

          [templates]
          log_node = ${"'''"}
          if(self && !current_working_copy && !immutable && !conflict && in_branch(self),
            "◇",
            builtin_log_node
          )
          ${"'''"}

          [template-aliases]
          "in_branch(commit)" = 'commit.contained_in("immutable_heads()..bookmarks()")'

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
          command = ["${config.home.homeDirectory}/.nix-profile/bin/clang-format", "--style=file", "--assume-filename=$path"]
          patterns = ["glob:'**/*.c'",
                      "glob:'**/*.h'"]

          [fix.tools.2-black]
          command = ["${config.home.homeDirectory}/.nix-profile/bin/black", "-", "--stdin-filename=$path"]
          patterns = ["glob:'**/*.py'"]

          [fix.tools.3-pre-commit]
          command = ["${config.home.homeDirectory}/.nix-profile/bin/uvx", "--with", "pre-commit", "jj-pre-push", "check"]
          patterns = ["glob:'*'"]

          [fix.tools.4-alejandra]
          command = ["${config.home.homeDirectory}/.nix-profile/bin/alejandra"]
          patterns = ["glob:'**/*.nix'"]
        '';
      };
    };
  };
}
