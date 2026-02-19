{ config, pkgs, lib, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      la = "ls -A";
      gs = "git status";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#pulse15";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
