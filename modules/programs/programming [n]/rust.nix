{...}: {
  flake.modules.homeManager.rust = {
    config,
    pkgs-unstable,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      rustup
      rust-bindgen
      rust-cbindgen
    ];
  };
}
