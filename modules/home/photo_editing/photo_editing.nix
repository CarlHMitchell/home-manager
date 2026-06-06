{...}: {
  flake.modules.homeManager.photo_editing = {
    config,
    lib,
    pkgs,
    ...
  }: {
    home.packages = with pkgs; [
      #packages
      gimp
      krita
      ansel
      # davinci-resolve 21.0 is provided via nixpkgs overlay in carl-nixos configuration.nix
      # The zip was added to the store with:
      # ~/home/Downloads
      # ❯ nix-store --add-fixed sha256 DaVinci_Resolve_21.0_Linux.zip
      # /nix/store/bl25bg1prq9av114sdi4c188cdaij730-DaVinci_Resolve_21.0_Linux.zip
      #
      # ~/home/Downloads took 2s
      # ❯ nix hash file --type sha256 DaVinci_Resolve_21.0_Linux.zip
      # sha256-+NIrRgoKOaGYrzFwZsZFP8cshpPXO5ZA2y6DIKYUi2I=
      davinci-resolve
      displaycal
      quickemu # VM manager, for Windows VM, for DxO
    ];
  };
}
