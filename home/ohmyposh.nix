{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    oh-my-posh
  ];

  xdg.configFile."ohmyposh/zen.toml".source = ../config/ohmyposh/zen.toml;
}
