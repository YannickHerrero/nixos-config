{ config, pkgs, lib, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./mpv.nix
    ./tmux.nix
    ./neovim.nix
    ./ohmyposh.nix
    ./theming.nix
  ];

  home.username = "sovereign";
  home.homeDirectory = "/home/sovereign";

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
