{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Core CLI
    git
    vim
    neovim
    wget
    curl
    htop
    unzip
    ripgrep
    fd
    tree
    man-pages
    fastfetch

    # GUI
    firefox
    mpv
    feh
    xclip
    dunst
    picom
    arandr
    pavucontrol
    networkmanagerapplet
    pcmanfm
  ];
}
