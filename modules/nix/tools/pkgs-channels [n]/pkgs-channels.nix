{ inputs, ... }: {
  flake.modules.homeManager.pkgs-channels = { pkgs, ... }: {
    _module.args.pkgs-unstable = import inputs.nixpkgs-unstable {
      system = pkgs.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
    _module.args.pkgs-oldstable = import inputs.nixpkgs-oldstable {
      system = pkgs.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
