{ config, pkgs, lib, ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
      vo = "gpu-next";
      profile = "gpu-hq";
    };
  };
}
