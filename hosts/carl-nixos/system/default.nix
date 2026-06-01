{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./services.nix
  ];

  networking.hostName = "carl-nixos";
  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your timezone: timedatectl list-timezones
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  users.users.carl = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "dialout" "plugdev" "docker"];
    shell = pkgs.fish;
  };

  # Required for fish to be a valid login shell
  programs.fish.enable = true;

  system.stateVersion = "25.11";
}
