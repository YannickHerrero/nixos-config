{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  xdg.configFile."nvim".source = ../config/nvim;

  home.packages = with pkgs; [
    gcc
    unzip
  ];
}
