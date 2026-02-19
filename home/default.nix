{ config, pkgs, lib, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./mpv.nix
  ];

  home.username = "yannick";
  home.homeDirectory = "/home/yannick";

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
