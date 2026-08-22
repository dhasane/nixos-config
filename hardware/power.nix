{ ... }:

{
  services.acpid.enable = true;

  # Firmware updates via LVFS (fwupdmgr refresh && fwupdmgr get-updates).
  services.fwupd.enable = true;

  # Intel thermal daemon — helps avoid throttling on the Latitude.
  services.thermald.enable = true;
}
