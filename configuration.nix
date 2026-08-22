{ config, pkgs, ... }:

let
  vars = import /etc/nixos/local/vars.nix { };
in

{
  _module.args = { inherit vars; };

  system.stateVersion = "25.11";

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./base.nix

      ./system/network.nix
      ./system/pruning.nix
      ./system/security.nix

      ./hardware/audio.nix
      ./hardware/bluetooth.nix
      ./hardware/fingerprint.nix
      ./hardware/input.nix
      ./hardware/memory.nix
      ./hardware/power.nix
      ./hardware/printing.nix
      ./hardware/storage.nix

      ./user/user.nix
      ./user/shell.nix
      ./user/home-manager.nix

      ./desktop/gnome.nix
      # ./desktop/xmonad.nix
      # ./desktop/i3.nix

      # optional
      # ./containers.nix
      ./apps.nix
    ];
}
