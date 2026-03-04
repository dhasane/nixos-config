{ config, pkgs, ... }:

{
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "latam";
    variant = "nodeadkeys";
    # options = "ctrl:swapcaps";
    # options = "caps:ctrl_modifier"; # handled by keyd (tap=Esc, hold=Ctrl)
  };

  services.keyd.enable = true;
  services.keyd.keyboards.default = {
    ids = [ "*" ];
    settings = {
      main = {
        # Dual-role Caps Lock: tap = Esc, hold = Ctrl
        capslock = "overload(control, esc)";
        leftcontrol = "overload(control, esc)";
      };
    };
  };

  # Configure console keymap
  console.keyMap = "es";

  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
  };

  # Configure keymap in X11
  # services.xserver.xkb = {
  #  layout = "us";
  #  variant = "";
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
}
