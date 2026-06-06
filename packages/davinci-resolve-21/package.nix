{
  stdenv,
  lib,
  requireFile,
  unzip,
  appimageTools,
  addDriverRunpath,
  dbus,
  libGLU,
  xkeyboard-config,
  libxcb-util,
  libxcb-wm,
  libxcb-render-util,
  libxcb-keysyms,
  libxcb-image,
  libxxf86vm,
  libxt,
  libxtst,
  libxrender,
  libxrandr,
  libxi,
  libxinerama,
  libxfixes,
  libxext,
  libxdamage,
  libxcursor,
  libxcomposite,
  libx11,
  libsm,
  libice,
  libxcb,
  buildFHSEnv,
  bash,
  writeText,
  writeShellScript,
  ocl-icd,
  xkeyboard_config,
  glib,
  libarchive,
  libxcrypt,
  python3,
  aprutil,
  makeDesktopItem,
  copyDesktopItems,
  jq,
  studioVariant ? false,
  common-updater-scripts,
  writeShellApplication,
  curl,
}: let
  davinci = (
    stdenv.mkDerivation rec {
      pname = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
      version = "21.0";

      nativeBuildInputs = [
        appimageTools.appimage-exec
        addDriverRunpath
        copyDesktopItems
        unzip
      ];

      buildInputs = [
        libGLU
        libxxf86vm
      ];

      src = requireFile {
        name = "DaVinci_Resolve_21.0_Linux.zip";
        url = "https://www.blackmagicdesign.com/products/davinciresolve";
        hash = "sha256-+NIrRgoKOaGYrzFwZsZFP8cshpPXO5ZA2y6DIKYUi2I=";
      };

      # The unpack phase won't generate a directory
      sourceRoot = ".";

      installPhase = let
        appimageName = "DaVinci_Resolve_${lib.optionalString studioVariant "Studio_"}${version}_Linux.run";
      in ''
        runHook preInstall

        export HOME=$PWD/home
        mkdir -p $HOME

        mkdir -p $out
        test -e ${lib.escapeShellArg appimageName}
        appimage-exec.sh -x $out ${lib.escapeShellArg appimageName}

        mkdir -p $out/{"Apple Immersive/Calibration",configs,DolbyVision,easyDCP,Extras,Fairlight,GPUCache,logs,Media,"Resolve Disk Database",.crashreport,.license,.LUT}

        # Install udev rules for Blackmagic hardware (color panels, Speed Editor, Editor Keyboard)
        mkdir -p $out/lib/udev/rules.d
        cp $out/share/etc/udev/rules.d/99-BlackmagicDevices.rules $out/lib/udev/rules.d/
        cp $out/share/etc/udev/rules.d/99-ResolveKeyboardHID.rules $out/lib/udev/rules.d/
        # Generate catch-all rules for Blackmagic Design vendor ID (096e)
        # USB device access (color panels, general hardware)
        echo 'SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="096e", MODE="0666"' \
          > $out/lib/udev/rules.d/99-DavinciPanel.rules
        # hidraw access (Speed Editor jog wheel, Editor Keyboard, future HID devices)
        echo 'KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="096e", MODE="0666"' \
          >> $out/lib/udev/rules.d/99-DavinciPanel.rules

        # Verify all three rules files are present
        test -f $out/lib/udev/rules.d/99-BlackmagicDevices.rules
        test -f $out/lib/udev/rules.d/99-ResolveKeyboardHID.rules
        test -f $out/lib/udev/rules.d/99-DavinciPanel.rules
        runHook postInstall
      '';

      dontStrip = true;

      postFixup = ''
        for program in $out/bin/*; do
          isELF "$program" || continue
          addDriverRunpath "$program"
        done

        for program in $out/libs/*; do
          isELF "$program" || continue
          if [[ "$program" != *"libcudnn_cnn_infer"* ]];then
            echo $program
            addDriverRunpath "$program"
          fi
        done
        ln -s $out/libs/libcrypto.so.1.1 $out/libs/libcrypt.so.1
      '';

      desktopItems =
        [
          (makeDesktopItem {
            name = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
            desktopName = "Davinci Resolve${lib.optionalString studioVariant " Studio"}";
            genericName = "Video Editor";
            exec = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
            icon = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
            comment = "Professional video editing, color, effects and audio post-processing";
            categories = [
              "AudioVideo"
              "AudioVideoEditing"
              "Video"
              "Graphics"
            ];
            startupWMClass = "resolve";
          })
          (makeDesktopItem {
            name = "blackmagicraw-player";
            desktopName = "Blackmagic RAW Player";
            exec = "blackmagicraw-player %f";
            icon = "blackmagicraw-player";
            mimeTypes = [
              "application/x-braw-clip"
              "application/x-braw-sidecar"
            ];
            categories = [
              "Video"
              "AudioVideo"
            ];
          })
          (makeDesktopItem {
            name = "blackmagicraw-speedtest";
            desktopName = "Blackmagic RAW Speed Test";
            exec = "blackmagicraw-speedtest";
            icon = "blackmagicraw-speedtest";
            categories = [
              "Video"
              "AudioVideo"
            ];
          })
          (makeDesktopItem {
            name = "davinci-control-panels-setup";
            desktopName = "DaVinci Control Panels Setup";
            exec = "davinci-control-panels-setup";
            icon = "davinci-control-panels-setup";
            categories = ["Settings"];
          })
          (makeDesktopItem {
            name = "davinci-fairlight-studio-utility";
            desktopName = "Fairlight Studio Utility";
            exec = "davinci-fairlight-studio-utility";
            icon = "davinci-fairlight-studio-utility";
            categories = [
              "AudioVideo"
              "Audio"
            ];
          })
        ]
        ++ lib.optional studioVariant (makeDesktopItem {
          name = "davinci-remote-monitor";
          desktopName = "DaVinci Remote Monitor";
          exec = "davinci-remote-monitor";
          icon = "davinci-remote-monitor";
          comment = "DaVinci Remote Monitor";
          categories = [
            "AudioVideo"
            "Video"
          ];
        });
    }
  );
in
  buildFHSEnv {
    inherit (davinci) pname version;

    targetPkgs = pkgs:
      with pkgs; [
        alsa-lib
        aprutil
        bzip2
        davinci
        dbus
        expat
        fontconfig
        freetype
        glib
        libGL
        libGLU
        libarchive
        libcap
        librsvg
        libtool
        libuuid
        libxcrypt
        libxkbcommon
        nspr
        ocl-icd
        opencl-headers
        python3
        python3.pkgs.numpy
        libdrm
        libxkbfile
        krb5
        nss
        libxcb-cursor
        udev
        xdg-utils
        libice
        libsm
        libx11
        libxcomposite
        libxcursor
        libxdamage
        libxext
        libxfixes
        libxi
        libxinerama
        libxrandr
        libxrender
        libxt
        libxtst
        libxxf86vm
        libxcb
        libxcb-util
        libxcb-image
        libxcb-keysyms
        libxcb-render-util
        libxcb-wm
        xkeyboard-config
        zlib
      ];

    extraPreBwrapCmds = lib.optionalString studioVariant ''
      mkdir -p ~/.local/share/DaVinciResolve/license || exit 1
      mkdir -p ~/.local/share/DaVinciResolve/Extras || exit 1
    '';

    extraBwrapArgs = lib.optionals studioVariant [
      ''--bind "$HOME"/.local/share/DaVinciResolve/license ${davinci}/.license''
      ''--bind "$HOME"/.local/share/DaVinciResolve/Extras ${davinci}/Extras''
    ];

    runScript = "${bash}/bin/bash ${writeText "davinci-wrapper" ''
      export QT_XKB_CONFIG_ROOT="${xkeyboard_config}/share/X11/xkb"
      export QT_PLUGIN_PATH="${davinci}/libs/plugins:$QT_PLUGIN_PATH"
      export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/lib32:${davinci}/libs
      if [ $# -gt 0 ]; then
        exec "$@"
      else
        exec ${davinci}/bin/resolve
      fi
    ''}";

    extraInstallCommands = let
      execName = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
      mkWrapper = name: bin:
        writeShellScript name ''
          exec "$(dirname "$0")/${execName}" ${bin} "$@"
        '';
      wrappers =
        {
          "blackmagicraw-player" = "${davinci}/BlackmagicRAWPlayer/BlackmagicRAWPlayer";
          "blackmagicraw-speedtest" = "${davinci}/BlackmagicRAWSpeedTest/BlackmagicRAWSpeedTest";
          "davinci-control-panels-setup" = ''"${davinci}/DaVinci Control Panels Setup/DaVinci Control Panels Setup"'';
          "davinci-fairlight-studio-utility" = ''"${davinci}/Fairlight Studio Utility/Fairlight Studio Utility"'';
        }
        // lib.optionalAttrs studioVariant {
          "davinci-remote-monitor" = ''"${davinci}/bin/DaVinci Remote Monitor"'';
        };
    in ''
      # Desktop files
      mkdir -p $out/share/applications
      ln -s ${davinci}/share/applications/*.desktop $out/share/applications/

      # Icons
      mkdir -p $out/share/icons/hicolor/{128x128,256x256}/apps
      ln -s ${davinci}/graphics/DV_Resolve.png $out/share/icons/hicolor/128x128/apps/davinci-resolve${lib.optionalString studioVariant "-studio"}.png
      ln -s ${davinci}/graphics/DV_Panels.png $out/share/icons/hicolor/128x128/apps/davinci-control-panels-setup.png
      ${lib.optionalString studioVariant ''
        ln -s ${davinci}/graphics/Remote_Monitoring.png $out/share/icons/hicolor/128x128/apps/davinci-remote-monitor.png
      ''}
      ln -s ${davinci}/graphics/blackmagicraw-player_256x256_apps.png $out/share/icons/hicolor/256x256/apps/blackmagicraw-player.png
      ln -s ${davinci}/graphics/blackmagicraw-speedtest_256x256_apps.png $out/share/icons/hicolor/256x256/apps/blackmagicraw-speedtest.png

      # Wrapper scripts for additional programs
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: bin: ''
          ln -s ${mkWrapper name bin} $out/bin/${name}
        '')
        wrappers
      )}

      # MIME type definitions for .drp, .braw, etc.
      mkdir -p $out/share/mime/packages
      ln -s ${davinci}/share/resolve.xml $out/share/mime/packages/
      ln -s ${davinci}/share/blackmagicraw.xml $out/share/mime/packages/

      # Expose udev rules so NixOS can aggregate them from environment.systemPackages
      mkdir -p $out/lib/udev/rules.d
      ln -s ${davinci}/lib/udev/rules.d/99-BlackmagicDevices.rules $out/lib/udev/rules.d/
      ln -s ${davinci}/lib/udev/rules.d/99-ResolveKeyboardHID.rules $out/lib/udev/rules.d/
      ln -s ${davinci}/lib/udev/rules.d/99-DavinciPanel.rules $out/lib/udev/rules.d/
    '';

    passthru = {
      inherit davinci;
    };

    meta = {
      description = "Professional video editing, color, effects and audio post-processing";
      homepage = "https://www.blackmagicdesign.com/products/davinciresolve";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [
        amarshall
        XBagon
        toXel
        cafkafk
      ];
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      mainProgram = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
    };
  }
