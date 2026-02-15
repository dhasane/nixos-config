{ config, pkgs, lib, username, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz;
in
{
  imports =
    [
      (import "${home-manager}/nixos")
    ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = import /home/${username}/.config/home-manager/home.nix;
  };
}
