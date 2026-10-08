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

          # Stack aliases from https://alan.norbauer.com/articles/stacks-in-jujutsu
          # See also https://alan.norbauer.com/articles/github-stacks-with-jujutsu/
          #  for use with Github stacked PRs
          [aliases.move-to]
          definition = ["util", "exec", "--", "bash", "-c", """
          cd "''${JJ_WORKSPACE_ROOT:-.}"
          revset=''$1
          shift
          edit=''$(jj config get ui.movement.edit 2>/dev/null || echo false)
          args=()
          for a in "''$@"; do
            case $a in
              -e|--edit)    edit=true ;;
              -n|--no-edit) edit=false ;;
              *)            args+=("''$a") ;;
            esac
          done
          if $edit; then verb=edit; else verb=new; fi
          exec jj "$verb" "''${args[@]}" "''$revset"
          """, "jj-move"]
          doc = "Move to a revset: new child of it, or edit it with -e"

          [aliases.bottom]
          definition = ["move-to", "stack_bottom()"]
          doc = "Move to the bottom of the current stack, stack_bottom()"

          [aliases.top]
          definition = ["move-to", "stack_top()"]
          doc = "Move to the top of the current stack, stack_top()"

          [aliases.sb]
          definition = ["stack-bookmarks"]
          doc = "Shorthand for stack-bookmarks"

          [aliases.stack-bookmarks]
          definition = [
            "--config",
            "revsets.log=substack()",
            "log",
            "--no-graph",
            "--reversed",
            "-T",
            'if(local_bookmarks, local_bookmarks.map(|b| b.name()).join(" ") ++ " ", "")'
          ]
          doc = "Local bookmark names in substack(@), oldest first, space-separated"

          [revset-aliases."stack_heads()"]
          definition = "stack_heads(@)"
          doc = "Newest mutable commits at or ahead of the working copy"

          [revset-aliases."stack_heads(to)"]
          definition = "heads(mutable() & to::)"
          doc = "Newest mutable commits at or ahead of to"

          [revset-aliases."stack_top()"]
          definition = "stack_top(@)"
          doc = "Newest mutable, single commit at or ahead of the working copy"

          [revset-aliases."stack_top(to)"]
          definition = "exactly(stack_heads(to), 1)"
          doc = "Newest mutable, single commit at or ahead of to"

          [revset-aliases."stack_bottom(to)"]
          definition = "roots(mutable() & ::to)"
          doc = "Oldest mutable commits at or behind to"

          [revset-aliases."stack_bottom()"]
          definition = "stack_bottom(@)"
          doc = "Oldest mutable commits at or behind the working copy"

          [revset-aliases."stack(to)"]
          definition = "stack_bottom(to)::stack_top(to)"
          doc = "Full stack containing to, from stack_bottom(to) to stack_top(to)"

          [revset-aliases."stack()"]
          definition = "stack(@)"
          doc = "Full stack containing the working copy, from its bottom to its top"

          [revset-aliases."substack(to)"]
          definition = "stack_bottom(to)::to"
          doc = "Stack containing to, from stack_bottom(to) through to"

          [revset-aliases."substack()"]
          definition = "substack(@)"
          doc = "Stack from its bottom through the working copy"

          [revset-aliases."tree()"]
          definition = "tree(@)"
          doc = "Full tree (all stacks) containing the working copy"

          [revset-aliases."tree(to)"]
          definition = "reachable(to, mutable())"
          doc = "Full tree (all stacks) containing to"

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

          [revset-aliases."closest_pushable(to)"]
          definition = 'heads(::to & mutable() & ~empty() & description(regex:".+"))'
          doc = "Closest mutable, non-empty, described commits at or behind to"

          [revsets]
          bookmark-advance-to = "closest_pushable(@)"

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
