{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;


  # Set your time zone.
  time.timeZone = "America/Bogota";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_CO.UTF-8";
    LC_IDENTIFICATION = "es_CO.UTF-8";
    LC_MEASUREMENT = "es_CO.UTF-8";
    LC_MONETARY = "es_CO.UTF-8";
    LC_NAME = "es_CO.UTF-8";
    LC_NUMERIC = "es_CO.UTF-8";
    LC_PAPER = "es_CO.UTF-8";
    LC_TELEPHONE = "es_CO.UTF-8";
    LC_TIME = "es_CO.UTF-8";
  };

  systemd.services.upower.enable = true;
  services.acpid.enable = true;

  # bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.git = {
    enable = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.activationScripts.pruneSystemGenerations.text = ''
    # Keep only the last 3 system generations after rebuild.
    ${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-generations +3
  '';

  systemd.services.nix-prune-generations-weekly = {
    description = "Prune NixOS system generations older than 7 days";
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      ${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-older-than 7d
    '';
  };

  systemd.timers.nix-prune-generations-weekly = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 8*1024;
  } ];

  services.udisks2.enable = true;
  services.devmon.enable = true;
}
