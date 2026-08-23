{inputs, ...}: {
  flake.modules.homeManager.iosevka-carl = {
    pkgs,
    lib,
    ...
  }: let
    iosevka-carl = pkgs.stdenvNoCC.mkDerivation {
      pname = "iosevka-carl";
      version = "custom";

      src = inputs.iosevka-carl-font;

      nativeBuildInputs = [pkgs.zstd];

      unpackPhase = ''
        tar -x --use-compress-program=unzstd -f $src
      '';

      installPhase = ''
        install -Dm644 IosevkaCarl/TTF/*.ttf -t $out/share/fonts/truetype/IosevkaCarl
        install -Dm644 IosevkaCarl/TTF-Unhinted/*.ttf -t $out/share/fonts/truetype/IosevkaCarl-Unhinted
        install -Dm644 IosevkaCarl/WOFF2/*.woff2 -t $out/share/fonts/woff2/IosevkaCarl
        install -Dm644 IosevkaCarl/WOFF2-Unhinted/*.woff2 -t $out/share/fonts/woff2/IosevkaCarl-Unhinted
      '';

      meta = {
        description = "Carl's custom Iosevka build";
        platforms = lib.platforms.all;
      };
    };
  in {
    home.packages = [iosevka-carl];
    fonts.fontconfig.enable = true;
  };
}
