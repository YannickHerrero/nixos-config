{ config, pkgs, lib, nixos-apple-silicon, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/suckless.nix
    ../../modules/audio.nix
    ../../modules/bluetooth.nix
    ../../modules/networking.nix
    ../../modules/locale.nix
    ../../modules/fonts.nix
    ../../modules/packages.nix
  ];

  # Hostname
  networking.hostName = "macbook-air";

  # Bootloader — systemd-boot (m1n1 -> U-Boot -> systemd-boot chain)
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
  };

  # Apple Silicon GPU
  hardware.asahi = {
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
  };

  # Graphics
  hardware.graphics.enable = true;

  # Apple Silicon overlay
  nixpkgs.overlays = [ nixos-apple-silicon.overlays.apple-silicon-overlay ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Zsh system-wide
  programs.zsh.enable = true;

  # User account
  users.users.sovereign = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "bluetooth" ];
  };

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.sovereign = import ../../home;
  };

  system.stateVersion = "24.11";
}
