# Declares work-specific options and contributes the work-only configuration
# (KTMR shell integration, AWS profile, git LFS / ignores, work git email) to the
# shared shell and vcs modules. Hosts that do not import this get none of it.
{self, ...}: {
  flake.modules.homeManager.work-profile = {
    config,
    lib,
    ...
  }: let
    cfg = config.work;
    home = config.home.homeDirectory;
  in {
    imports = [self.modules.homeManager.vcs-identity];

    options.work = {
      gitEmail = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Work email for git and jj commits.";
      };

      awsProfile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "AWS profile name to export as AWS_PROFILE / AWS_DEFAULT_PROFILE.";
      };

      ktmrEnabled = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Enable KTMR-specific shell integrations: sources ~/.config/ktmr/load.sh,
          sets KTMR_DIRENV_SKIP_NIX_VERSION_CHECK and KTMR_PATH, adds kt repo
          shell aliases, and includes kt-specific git ignore paths and LFS config.
        '';
      };

      jjPrePushCheckerScript = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to a prek checker script. Enables the pushk/checkk jj aliases when non-null.";
      };
    };

    config = lib.mkMerge [
      # Normal priority, it beats the personal profile's mkDefault email.
      (lib.mkIf (cfg.gitEmail != "") {
        vcs.email = cfg.gitEmail;
      })

      (lib.mkIf (cfg.awsProfile != null) {
        programs.zsh.initContent = ''
          export AWS_PROFILE="${cfg.awsProfile}"
        '';
        programs.bash.initExtra = ''
          export AWS_DEFAULT_PROFILE="${cfg.awsProfile}"
        '';
      })

      (lib.mkIf cfg.ktmrEnabled {
        programs.zsh = {
          initContent = ''
            export KTMR_DIRENV_SKIP_NIX_VERSION_CHECK="iknowwhatimdoing"
            if [ -f "${home}/.config/ktmr/load.sh" ]; then
              source "${home}/.config/ktmr/load.sh"
            fi
            via_changelog() { git log "--pretty=oneline" "--abbrev-commit" "$(git tag | grep "via_app-$1")..HEAD" "${home}/code/KeepTruckin/kt/src/embedded/via" && git log "--pretty=oneline" "--abbrev-commit" "$(git tag | grep "via_app-$1")..HEAD" "${home}/code/KeepTruckin/kt/src/proto/embedded/via" }
            viac() { minicom -c on -O timestamp=extended -C ~/tmp/via_console_$(date -Is).log -D "/dev/serial/by-id/usb-FTDI_FT232R_USB_UART_A90879CT-if00-port0" -b 115200 -8 }
            vg5c() { minicom -c on -O timestamp=extended -C ~/tmp/vg5_console_$(date -Is).log -D "/dev/ttyVIA$1" -b 115200 -8 }
            fixtemp ()
            {
              local tempdir="''$(nix-shell --help 2>&1 | rg "error: creating directory '/tmp/nix-shell.*': No such file or directory" | cut -d ' ' -f 4 | cut -b 2- | cut -d '/' -f -3 | cut -d '/' -f 3-)"
              if [ -n "/tmp/''${tempdir}" ]; then
                mkdir -p "/tmp/''${tempdir}"
              fi
            }
            fixtemp
          '';
          shellAliases = {
            emb = "cd ~/code/KeepTruckin/kt/src/embedded";
            via = "cd ~/code/KeepTruckin/kt/src/embedded/via";
            ktpc = "$KTMR_PATH/.git/hooks/pre-commit";
          export_motive_secrets = ''
            ORG_GRADLE_PROJECT_nexusUser="$(fnox get --config ~/code/KeepTruckin/fnox.toml nexusUser)"
            ORG_GRADLE_PROJECT_nexusPassword="$(fnox get --config ~/code/KeepTruckin/fnox.toml  nexusPassword)"
            export ORG_GRADLE_PROJECT_nexusUser
            export ORG_GRADLE_PROJECT_nexusPassword
          '';
          build_vehicle_service = ''
            export JAVA_HOME=/home/carl/code/KeepTruckin/aidcplus/motive_aosp/src/vg5/tools/jdk17
            ./gradlew --max-workers="$(( ($(nproc) / 2) -1))" :service:assembleDebug;
          '';
          };
        };

        programs.bash.initExtra = ''
          if [ -f "${home}/.config/ktmr/load.sh" ]; then
            source "${home}/.config/ktmr/load.sh"
          fi
          export KTMR_DIRENV_SKIP_NIX_VERSION_CHECK="iknowwhatimdoing"
          export KTMR_PATH="${home}/code/KeepTruckin/kt"
        '';

        programs.fish.interactiveShellInit = ''
          set -x KTMR_DIRENV_SKIP_NIX_VERSION_CHECK "iknowwhatimdoing"
        '';

        programs.git = {
          settings.lfs."https://gerrit.corp.ktdev.io/android/device/motive/services/VehicleService.git/info/lfs".locksverify = true;
          ignores = [
            # Some folders in KTMR
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/embedded/via/workspace/.venv"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/embedded/via/workspace/.envrc"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/embedded/via/workspace/.python-version"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/embedded/via/workspace/pyproject.toml"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/embedded/via/workspace/default.nix"
            # Git-LFS files since JJ doesn't support them as of 2025-10
            #  Tracking issue: https://github.com/jj-vcs/jj/issues/80
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/embedded/astro/ambalink/sources/kt_mcu/stm32l073/zephyr_app.bin"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/embedded/astro/ambalink/sources/kt_mcu/stm32l073/zephyr_full.bin"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/embedded/ff/applications/asset_tracker_v2/doc/forbidden_camping_attach_reject.png"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/embedded/ff/applications/asset_tracker_v2/doc/forbidden_camping_non_attach.png"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/embedded/lbb_sdk/svcs/kthw/scripts/des_fota/fw/logs_embedded-es-2-release_1912907051768483840_artifacts_v13108_es2_13108_E21B_E21C_E21D_E31A_E31B.bin"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/embedded/tools/docker/bc_hbii/JLink_Linux_V818_x86_64.deb"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/embedded/via/workspace/motive/modules/boards/arm/stm32g4_disco/doc/img/stm32g4_disco.jpg"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/embedded/via/workspace/motive/apps/via_mps_bl_flasher/images/bootloader.bin"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/fleet/services/safety-video-transcoder/static/static.zip"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/platform/services/file-ingestion/app/domain/service/testdata/caa25b4d-6c10-46d1-be0a-42cf64ce79ab.dpe"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/platform/services/file-ingestion/app/domain/service/testdata/invalid_too_short.dpe"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/qa-sqa/automation-framework/docs/RunTestClassFromProjectExplorer.png"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/qa-sqa/automation-framework/docs/RunTestClassInline.png"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/qa-sqa/automation-framework/docs/TestClassInSearchResult.png"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/qa-sqa/automation-framework/gomotive-system-tests/browser-system-tests/src/test/resources/FileUpload/invalid-training-video.mp4"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/qa-sqa/automation-framework/gomotive-system-tests/browser-system-tests/src/test/resources/FileUpload/valid-training-video.mp4"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/rnd/vision/data_preparation_scripts/road_facing/data_wrapper/core/image-1.png"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/rnd/vision/data_preparation_scripts/road_facing/data_wrapper/core/image.png"
            "${config.home.homeDirectory}/code/KeepTruckin/kt/src/safety/terraform_v2/multi/us-east-1/preview/annotationtool/lambda_function.zip"
          ];
        };
      })
    ];
  };
}
