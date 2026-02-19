{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/suckless.nix
    ../../modules/graphics.nix
    ../../modules/audio.nix
    ../../modules/bluetooth.nix
    ../../modules/networking.nix
    ../../modules/locale.nix
    ../../modules/power.nix
    ../../modules/fonts.nix
    ../../modules/packages.nix
  ];

  # Hostname
  networking.hostName = "pulse15";

  # Bootloader — GRUB with EFI and os-prober for Windows dual-boot
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
    };
  };

  # Dual-boot clock compatibility (Windows uses localtime)
  time.hardwareClockInLocalTime = true;

  # Blacklist NVIDIA — Intel iGPU only
  boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # User account
  users.users.yannick = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "bluetooth" ];
  };

  # Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.yannick = import ../../home;
  };

  system.stateVersion = "24.11";
}
