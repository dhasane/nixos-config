{ config, pkgs, username, lib, ... }:

{
  virtualisation.docker.enable = true;

  users.users.${username}.extraGroups = lib.mkAfter [ "docker" ];
}
