{ config, pkgs, lib, ... }:

{
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      jetbrains-mono
      liberation_ttf
    ];

    fontconfig.defaultFonts = {
      monospace = [ "JetBrains Mono" ];
    };
  };
}
