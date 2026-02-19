{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    pywal
    feh
    nsxiv
  ];

  # Pywal templates — wal generates themed configs from these
  xdg.configFile."wal/templates".source = ../config/wal/templates;

  # Install wall-set script
  home.file.".local/bin/wall-set" = {
    source = ../scripts/wall-set;
    executable = true;
  };
}
