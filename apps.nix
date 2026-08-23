{ pkgs, ... }:

{

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  programs.steam = {
    enable = true;
    # remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    # dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  }; # ];

  programs.firefox.enable = true;
  programs.chromium.enable = true;

  programs.thunderbird.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    direnv
    ripgrep
    wget
    zsh

    libreoffice
    gparted
    # kitty
    ghostty
    # thunderbird
    # cura
    unzip

    # krita

    (emacs.pkgs.withPackages (epkgs: [
      epkgs.jinx
    ]))
    gcc
    enchant
    hunspellDicts.en_US
    hunspellDicts.es_CO
    groff

    spotify

    calibre

    gh
    git
    neovim

    usbutils

    # Secure Boot key management + verification (used by system/lanzaboote.nix).
    sbctl

    discord
    claude-code
    # claude-agent-acp

    # drawio
    gotop
  ];
}
