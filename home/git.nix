{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    userName = "Yannick";
    userEmail = "TODO";
    delta.enable = true;
  };
}
