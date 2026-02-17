{ pkgs, lib, ... }:

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
}
