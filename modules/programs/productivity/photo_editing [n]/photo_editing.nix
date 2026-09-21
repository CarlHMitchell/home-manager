{...}: {
  flake.modules.homeManager.photo_editing = {
    config,
    lib,
    pkgs,
    pkgs-unstable,
    ...
  }: {
    home.packages = (with pkgs; [
      gimp
      krita
      ansel
      displaycal
      quickemu # VM manager, for Windows VM, for DxO
      geeqie
      exiftool
      darktable
    ]) ++ (with pkgs-unstable; [
      # davinci-resolve
    ]);
  };
}
