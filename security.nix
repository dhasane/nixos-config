{ config, pkgs, lib, vars, ... }:

let
  luksList = vars.luksdevices;
  luksDevices = builtins.listToAttrs (map (uuid: {
    name = "luks-${uuid}";
    value = {
      device = "/dev/disk/by-uuid/${uuid}";
      # add other per-device options here, e.g. preLVM = true;
    };
  }) luksList);
in
{
  security.pam.services = {
    login = {
      u2fAuth = true;
      fprintAuth = false;
    };

    sudo = {
      fprintAuth = false;
      unixAuth = true;
      u2fAuth = true;
    };
  };

  boot.initrd.luks.devices = luksDevices;

}
