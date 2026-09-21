{inputs, ...}: {
  flake-file.inputs = {
    iosevka-carl-font.url = "file:///home/carl/.config/nix-configs/binaries/IosevkaCarl.tar.zstd";
    iosevka-carl-font.flake = false;
  };
}
