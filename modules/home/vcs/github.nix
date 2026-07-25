{...}: {
    flake.modules.homeManager.github = {
    config,
    lib,
    pkgs,
    ...}: {
        programs.gh = {
            enable = true;
        };
    };
}
