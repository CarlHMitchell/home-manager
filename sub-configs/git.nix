{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    signing.signByDefault = true;
    signing.key = "/home/carl/.ssh/id_ed25519.pub";
    settings = {
      user.name = "Carl Mitchell";
      user.email = "carl.mitchell@gomotive.com";
      alias = {
        unstage = "reset -q HEAD --";
        discard = "checkout --";
        nevermind = "!f() { git reset --hard HEAD^ && git clean -d -f; }; f";
        uncommit = "reset --mixed HEAD~";
        summary = "status -u -s";
        graph = "log --graph -10 --branches --remotes --tags  --format=format:'%Cgreen%h %Creset• %<(75,trunc)%s (%cN, %ar) %Cred%d' --date-order";
        history = "log -10 --format=format:'%Cgreen%h %Creset%s (%aN, %ar)'";
        log-all = "log --all --graph --oneline --decorate";
        new-branch = "checkout -b";
        rename-branch = "branch -m";
        delete-branch = "branch -D";
        branches = "branch";
        recent-branches = "branch -a --sort=committerdate";
        merge-from = "merge";
        rebase-to = "rebase";
        tags = "tag";
        stashes = "stash list";
        remotes = "remote -v";
        unmerged = "branch --no-merged";
        untrack = "rm -r --cached";
        amend = "commit --amend --no-edit";
        amend-message = "commit --amend";
        current-branch = "rev-parse --abbrev-ref HEAD";
        aliases = "!git config --get-regexp ^alias\\. | sed -e s/^alias\\.// -e s/\\ /\\:\\ /";
        axe = "log --reverse -p -w -S";
        clean-untracked = "clean -d -f -x";
        force-pull-master = "!f() { git fetch && git reset --hard origin/master; }; f";
        force-pull-main = "!f() { git fetch && git reset --hard origin/main; }; f";
        sha = "rev-parse HEAD";
        ssha = "rev-parse --short HEAD";
        precommit = "!f() { git diff --cached --diff-algorithm=minimal -w; }; f";
        fpm = "!f() { git checkout master && git fetch && git pull --ff-only; }; f";
        fp = "!f() { git fetch && git pull --ff-only; }; f";
        prune-branches = ''!f() { git fetch -p && git checkout -q master && git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do mergeBase=$(git merge-base master $branch) && [[ $(git cherry master $(git commit-tree $(git rev-parse "$branch^{tree}") -p $mergeBase -m _)) == "-"* ]] && git branch -D $branch; done }; f'';
        gone = "!f() { git fetch --all --prune; git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D; }; f";
        push-new = ''!f() { git push --set-upstream origin "$(git rev-parse --abbrev-ref HEAD)"; }; f'';
        tag-message = ''tag --format='%(color:bold)%(describe)%0a%(contents)' -l "$1"'';
      };
      core = {
        autoclrf = "input";
        fsmonitor = true;
        untrackedCache = true;
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      rebase = {
        autosquash = true;
        autostash = true;
      };
      commit.verbose = true;
      diff = {
        colorMoved = "plain";
        algorithm = "histogram";
        mnemonicPrefix = true;
        renames = true;
      };
      feature.experimental = true;
      branch.sort = "committerdate";
      tag.sort = "version:refname";
      fetch = {
        prune = true;
        # pruneTags = true;
        all = true;
      };
      help.autocorrect = "prompt";
      apply.whitespace = "fix";
      log.date = "iso";
      gpg.format = "ssh";
    };
    lfs.enable = true;
    maintenance = {
      enable = true;
    };
    ignores = [
      # OS generated files
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "ehthumbs.db"
      "Thumbs.db"
      ".directory"

      # IDE files #
      ".idea/"
      ".vscode/"
      ".settings/"

      # CMake outputs #
      "CMakeFiles/"
      #*.cmake
      "progress.marks"
      "*.dir"
      "*.cbp"
      "Makefile"
      "CMakeCache.txt"
      "compile_commands.json"

      # Compiled source #
      "*.com"
      "*.class"
      "*.dll"
      "*.exe"
      "*.o"
      "*.so"
      "*.a"

      "~/.cache/*"

      # Some folders in KTMR
      "/home/carl/code/KeepTruckin/kt/src/embedded/via/workspace/.venv"
      "/home/carl/code/KeepTruckin/kt/src/embedded/via/workspace/.envrc"
      "/home/carl/code/KeepTruckin/kt/src/embedded/via/workspace/.python-version"
      "/home/carl/code/KeepTruckin/kt/src/embedded/via/workspace/pyproject.toml"
      "/home/carl/code/KeepTruckin/kt/src/embedded/via/workspace/default.nix"
      # Git-LFS files since JJ doesn't support them as of 2025-10
      #  Tracking issue: https://github.com/jj-vcs/jj/issues/80
      "/home/carl/code/KeepTruckin/kt/src/embedded/astro/ambalink/sources/kt_mcu/stm32l073/zephyr_app.bin"
      "/home/carl/code/KeepTruckin/kt/src/embedded/astro/ambalink/sources/kt_mcu/stm32l073/zephyr_full.bin"
      "/home/carl/code/KeepTruckin/kt/src/embedded/ff/applications/asset_tracker_v2/doc/forbidden_camping_attach_reject.png"
      "/home/carl/code/KeepTruckin/kt/src/embedded/ff/applications/asset_tracker_v2/doc/forbidden_camping_non_attach.png"
      "/home/carl/code/KeepTruckin/kt/src/embedded/lbb_sdk/svcs/kthw/scripts/des_fota/fw/logs_embedded-es-2-release_1912907051768483840_artifacts_v13108_es2_13108_E21B_E21C_E21D_E31A_E31B.bin"
      "/home/carl/code/KeepTruckin/kt/src/embedded/tools/docker/bc_hbii/JLink_Linux_V818_x86_64.deb"
      "/home/carl/code/KeepTruckin/kt/src/embedded/via/workspace/motive/modules/boards/arm/stm32g4_disco/doc/img/stm32g4_disco.jpg"
      "/home/carl/code/KeepTruckin/kt/src/embedded/via/workspace/motive/apps/via_mps_bl_flasher/images/bootloader.bin"
      "/home/carl/code/KeepTruckin/kt/src/fleet/services/safety-video-transcoder/static/static.zip"
      "/home/carl/code/KeepTruckin/kt/src/platform/services/file-ingestion/app/domain/service/testdata/caa25b4d-6c10-46d1-be0a-42cf64ce79ab.dpe"
      "/home/carl/code/KeepTruckin/kt/src/platform/services/file-ingestion/app/domain/service/testdata/invalid_too_short.dpe"
      "/home/carl/code/KeepTruckin/kt/src/qa-sqa/automation-framework/docs/RunTestClassFromProjectExplorer.png"
      "/home/carl/code/KeepTruckin/kt/src/qa-sqa/automation-framework/docs/RunTestClassInline.png"
      "/home/carl/code/KeepTruckin/kt/src/qa-sqa/automation-framework/docs/TestClassInSearchResult.png"
      "/home/carl/code/KeepTruckin/kt/src/qa-sqa/automation-framework/gomotive-system-tests/browser-system-tests/src/test/resources/FileUpload/invalid-training-video.mp4"
      "/home/carl/code/KeepTruckin/kt/src/qa-sqa/automation-framework/gomotive-system-tests/browser-system-tests/src/test/resources/FileUpload/valid-training-video.mp4"
      "/home/carl/code/KeepTruckin/kt/src/rnd/vision/data_preparation_scripts/road_facing/data_wrapper/core/image-1.png"
      "/home/carl/code/KeepTruckin/kt/src/rnd/vision/data_preparation_scripts/road_facing/data_wrapper/core/image.png"
      "/home/carl/code/KeepTruckin/kt/src/safety/terraform_v2/multi/us-east-1/preview/annotationtool/lambda_function.zip"

      # Jujutsu colocated with git has its own directory
      ".jj/"
    ];
  };

  programs.lazygit = {
    enable = true;
  };
}
