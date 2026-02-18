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
      ./user.nix
      ./shell.nix
      ./base.nix
      ./containers.nix
      ./network.nix
      ./home-manager.nix
      ./fingerprint.nix
      ./security.nix
      ./input.nix
      ./apps.nix
      ./gnome.nix
      # ./wm/xmonad.nix
      # ./wm/i3.nix
    ];
}
