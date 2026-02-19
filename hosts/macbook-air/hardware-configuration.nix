# TODO: Generate this file on the actual machine with:
#   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
#
# This file should contain filesystem mounts, kernel modules,
# and hardware-specific settings detected by NixOS.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Placeholder — replace with actual hardware config
  boot.initrd.availableKernelModules = [ ];
  boot.kernelModules = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
}
