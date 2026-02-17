{ pkgs, lib, ... }:

{
  # Fingerprint sensor (Broadcom ControlVault 3) via fprintd-tod
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd-tod;
    tod.enable = true;
    tod.driver = pkgs.libfprint-2-tod1-broadcom;
  };

  # Smartcard support for the ControlVault's smartcard interface (optional)
  services.pcscd.enable = true;
  environment.systemPackages = lib.mkAfter (with pkgs; [
    ccid
    opensc
  ]);
}
