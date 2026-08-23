{ lib, ... }:

# Secure Boot via lanzaboote. DO NOT import this file until you have:
#
#   1. Verified BIOS is in Setup Mode (Security → Secure Boot in BIOS Setup;
#      may require "Reset all keys" / "Clear PK" to enter Setup Mode).
#      Confirm with `sudo sbctl status` — should read "Setup Mode: Enabled".
#   2. Generated keys:    sudo sbctl create-keys
#   3. Enrolled keys:     sudo sbctl enroll-keys --microsoft
#      (The --microsoft flag preserves Microsoft's keys so fwupd BIOS
#      updates and standard installer USBs still boot.)
#
# After importing this file and running `nixos-rebuild switch`:
#   4. Verify all boot artifacts are signed: sudo sbctl verify
#      Every entry should show a ✓. Fix any ✗ before rebooting.
#   5. Reboot into BIOS, enable Secure Boot, save.
#   6. Boot back into NixOS, confirm:
#          bootctl status           # Secure Boot: enabled (user)
#          mokutil --sb-state       # SecureBoot enabled

{
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
}
