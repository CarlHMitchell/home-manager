{inputs, ...}: {
  # default settings needed for normal homeManagerConfigurations
  flake.modules.homeManager.user-default = {
    config,
    pkgs,
    pkgs-unstable,
    pkgs-oldstable,
    lib,
    ...
  }: {
    imports = with inputs.self.modules.homeManager; [
      user-minimal
      helix
      git
      xcompose
      zsh
      zellij
      starship
      jj
      uv
    ];

    services = {
      ssh-agent.enable = true;
    };
    # Nicely reload services when changing configs.
    systemd.user.startServices = "sd-switch";

    programs = {
      starship = {
        enable = true;
        enableZshIntegration = true;
      };

      ssh.settings."*".AddKeysToAgent = "yes";

      jujutsu = {
        enable = true;
        package = pkgs-unstable.jujutsu;
      };

      difftastic = {
        enable = true;
        git.enable = true;
        options.background = "dark";
      };

      zoxide = {
        enable = true;
        enableZshIntegration = true;
        options = ["--cmd cd"];
      };
    };

    home.packages =
      (with pkgs; [
        nix-output-monitor
        difftastic
        watchman
        alejandra
        nixfmt-tree
        gh
        systemctl-tui
        atuin
        lsof
        jj-fzf
        btop
        pay-respects
        fzf
        b3sum
        black
        fd
        ripgrep
        nix-index
        any-nix-shell
        zsh
        zsh-z
        zsh-fzf-tab
        zsh-autocomplete
        zsh-you-should-use
        zsh-autosuggestions
        zsh-syntax-highlighting
        nix-zsh-completions
        eza
        nixpkgs-fmt
        age
      ])
      ++ (with pkgs-unstable; [
        ])
      ++ (with pkgs-oldstable; [
        ]);
  };
}
