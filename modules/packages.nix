{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Core CLI
    git
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
    zoxide
    fzf
    eza
    bat
    lazygit
    delta

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
