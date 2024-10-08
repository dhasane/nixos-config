# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./base.nix
      ./network.nix
      # ./wm/xmonad.nix
      ./wm/i3.nix
    ];

  networking.hostName = "vestigo"; # Define your hostname.

  # Configure keymap in X11
  services.xserver = {
    layout = "latam";
    xkbVariant = "nodeadkeys,";
    # xkbOptions = "ctrl:swapcaps";
    xkbOptions = "caps:ctrl_modifier";
  };

  # Configure console keymap
  console.keyMap = "es";

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
    };
    # history = {
    #   size = 10000;
    #   # path = "${config.xdg.dataHome}/zsh/history";
    # };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.daniel = {
    isNormalUser = true;
    description = "daniel";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
    ];
  };

  users.extraUsers.daniel = {
    shell = pkgs.zsh;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  # services.emacs.package = pkgs.emacsPgtkNativeComp;

  # nixppgs.overlays = [
  # (import (builtins.fetchGit {
  #    url = "https://github.com/nix-community/emacs-overlay.git";
  #    ref = "master";
  # }))

  # programs.steam = {
  #     enable = true;
  #     remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #     dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  #   }; # ];

  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
  };

  virtualisation.docker.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    # pcmanfm
    xfce.thunar

    libreoffice
    # (let
    #   office = libreoffice-fresh-unwrapped;
    # in {
    #   environment.sessionVariables = {
    #     PYTHONPATH = "${office}/lib/libreoffice/program";
    #     URE_BOOTSTRAP = "vnd.sun.star.pathname:${office}/lib/libreoffice/program/fundamentalrc";
    #   };
    # })

    direnv
    dunst
    firefox
    gparted
    kitty
    networkmanagerapplet
    picom
    rofi
    teams
    thunderbird
    # tdesktop # telegram
    upower
    # xmobar

    cura

    eww

    krita

    unzip

    # dev
    cmake
    cargo
    ccls
    emacs
    gh
    gcc
    git
    glibc
    neovim
    nmap
    ripgrep
    sqlite
    tmux
    wget
    zsh

    # scala
    coursier

    # emacsPgtkNativeComp

    # python
    (let
      my-python-packages = python-packages: with python-packages; [
        pandas
        requests
        numpy
        mamba
        #other python packages you want
      ];
      python-with-my-packages = python3.withPackages my-python-packages;
    in
      python-with-my-packages)

    python39Packages.poetry
    jupyter

    zig

    # # haskell
    # ghc
    # haskellPackages.haskell-language-server
    # haskellPackages.hoogle
    # cabal-install
    # stack
  ];
}
