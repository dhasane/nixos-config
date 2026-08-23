{ config, pkgs, lib, vars, myhome, ... }:

let
  username = vars.username;
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = import "${myhome}/home.nix";
  };
}
