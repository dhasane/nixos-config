{ config, pkgs, vars, lib, ... }:

let
  username = vars.username;
in
{
  virtualisation.docker.enable = true;
  virtualisation.docker.package = pkgs.docker_29;

  users.users.${username}.extraGroups = lib.mkAfter [ "docker" ];
}
