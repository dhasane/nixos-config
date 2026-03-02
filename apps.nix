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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    direnv
    ripgrep
    wget
    zsh

    libreoffice
    gparted
    kitty
    thunderbird
    cura
    unzip

    krita

    emacs
    gh
    git
    neovim

    usbutils

    discord
  ];
}
