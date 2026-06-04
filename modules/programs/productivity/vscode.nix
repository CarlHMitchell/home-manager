{...}: {
  flake.modules.homeManager.vscode = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode-fhs;
      mutableExtensionsDir = true;
      profiles.default = {
        enableExtensionUpdateCheck = true;
        extensions = with pkgs.vscode-extensions; [
          bbenoist.nix
          ms-vscode.cpptools
          yzhang.markdown-all-in-one
          ms-python.python
          timonwong.shellcheck
          twxs.cmake
          ms-vscode.cmake-tools
          rust-lang.rust-analyzer
          mechatroner.rainbow-csv
          ms-azuretools.vscode-docker
          xaver.clang-format
          arrterian.nix-env-selector
          mkhl.direnv
          zxh404.vscode-proto3
          eamodio.gitlens
          ms-toolsai.jupyter
          ms-toolsai.vscode-jupyter-slideshow
          ms-toolsai.vscode-jupyter-cell-tags
          ms-toolsai.jupyter-renderers
          ms-toolsai.jupyter-keymap
          jnoortheen.nix-ide
          ms-vscode.makefile-tools
          davidanson.vscode-markdownlint
          jebbs.plantuml
          shd101wyy.markdown-preview-enhanced
          visualjj.visualjj
        ];
      };
    };
  };
}
