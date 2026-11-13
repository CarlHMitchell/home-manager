{...}: {
  flake.modules.homeManager.zellij = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.zellij = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      settings = {
        # copy_on_select = false;
        copy_command = "wl-copy";
        default_shell = "${pkgs.zsh}/bin/zsh";
        show_startup_tips = false;
      };
    };

    # Default layout (mirrors the built-in one) plus swap layouts for deterministic pane placement:
    #   2 panes: left | right
    #   3 panes: left | (right top / right bottom)
    #   4+ panes: (left top / left bottom) | (right top / right bottom ...)
    xdg.configFile."zellij/layouts/default.kdl".text = ''
      layout {
          default_tab_template {
              pane size=1 borderless=true {
                  plugin location="zellij:tab-bar"
              }
              children
              pane size=2 borderless=true {
                  plugin location="zellij:status-bar"
              }
          }
          tab
          swap_tiled_layout name="two" {
              tab max_panes=2 {
                  pane split_direction="vertical" {
                      pane
                      pane
                  }
              }
          }
          swap_tiled_layout name="three" {
              tab max_panes=3 {
                  pane split_direction="vertical" {
                      pane
                      pane split_direction="horizontal" {
                          pane
                          pane
                      }
                  }
              }
          }
          swap_tiled_layout name="four" {
              tab min_panes=4 {
                  pane split_direction="vertical" {
                      pane split_direction="horizontal" {
                          pane
                          pane
                      }
                      pane split_direction="horizontal" {
                          pane
                          pane
                      }
                  }
              }
          }
      }
    '';
  };
}
