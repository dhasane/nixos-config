{ config, pkgs, lib, ... }:

let
  # Auto-derive LUKS unlock entries for any encrypted swap declared in
  # hardware-configuration.nix as `/dev/mapper/luks-<uuid>`. Keeps the
  # UUID a single source of truth — on reinstall, only the hardware
  # config needs to be regenerated; nothing else to hand-sync.
  luksSwapUuids = map
    (dev: lib.removePrefix "/dev/mapper/luks-" dev.device)
    (lib.filter
      (dev: lib.hasPrefix "/dev/mapper/luks-" dev.device)
      config.swapDevices);

  luksDevices = builtins.listToAttrs (map (uuid: {
    name = "luks-${uuid}";
    value = {
      device = "/dev/disk/by-uuid/${uuid}";
    };
  }) luksSwapUuids);
in
{
  boot.initrd.luks.devices = luksDevices;

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

  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
}
