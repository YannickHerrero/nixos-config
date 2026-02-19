{ config, pkgs, lib, ... }:

let
  myDwm = pkgs.dwm.overrideAttrs (old: {
    src = ../suckless/dwm;
  });

  mySt = pkgs.st.overrideAttrs (old: {
    src = ../suckless/st;
  });

  myDmenu = pkgs.dmenu.overrideAttrs (old: {
    src = ../suckless/dmenu;
  });
in
{
  # X11 with French AZERTY layout
  services.xserver = {
    enable = true;
    xkb.layout = "fr";

    windowManager.dwm = {
      enable = true;
      package = myDwm;
    };

    displayManager.lightdm.enable = true;
  };

  environment.systemPackages = [
    mySt
    myDmenu
    pkgs.slock
    pkgs.slstatus

    # Build dependencies for compiling suckless tools locally
    pkgs.xorg.libX11
    pkgs.xorg.libXft
    pkgs.xorg.libXinerama
    pkgs.gcc
    pkgs.gnumake
    pkgs.pkg-config
  ];
}
