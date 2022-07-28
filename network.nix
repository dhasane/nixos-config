{ config, pkgs, ... }:
{

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.networkmanager.enable = true;
  # networking.networkmanager.packages = [ pkgs.networkmanagerapplet  ];
  networking.networkmanager.unmanaged = [ "docker0" ];
  # networking.nameservers = [ "<IP>" ];

  programs.nm-applet.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
}
