{...}: {
  flake.homeModules.uv = {config, ...}: {
    home.file = {
      "${config.xdg.configHome}/uv/uv.toml" = {
        text = ''
          exclude-newer = "7 days"
        '';
        force = true;
      };
    };
  };
}
