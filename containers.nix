{ config, pkgs, vars, lib, ... }:

let
  username = vars.username;
in
{
  virtualisation.docker.enable = true;

  users.users.${username}.extraGroups = lib.mkAfter [ "docker" ];
}
