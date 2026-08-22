
{ config, pkgs, ... }:
{
  environment.pathsToLink = [ "/libexec" ];
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Enable the Enlightenment Desktop Environment.
    displayManager.lightdm.enable = true;

    # desktopManager.enlightenment.enable = true;
    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
        defaultSession = "none+xmonad";
    };

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
        haskellPackages.dbus
        haskellPackages.List
        haskellPackages.monad-logger
        haskellPackages.xmobar
      ];
    };
  };
}
