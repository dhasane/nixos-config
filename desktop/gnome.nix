{ lib, config, pkgs, vars, ... }:

let
  username = vars.username;
in
{
  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = (with pkgs; [
    # gnome-photos
    gnome-tour
    gnome-music
    epiphany # web browser
    geary # email reader
    yelp # Help view
    gnome-contacts
    gnome-initial-setup
  # ]) ++ (with pkgs.gnome; [
  #   # gnome-characters
  ]);

  # environment.systemPackages = with pkgs; [
  #   gnome-tweaks
  # ];

  programs.dconf.enable = true;

  programs.dconf.profiles.user.databases = [
    {
      lockAll = true; # prevents overriding
      settings = {
        "org/gnome/desktop/input-sources" = {
          # xkb-options = [ "ctrl:nocaps" ]; # handled by keyd (tap=Esc, hold=Ctrl)
          sources = [
            (lib.gvariant.mkTuple [ "xkb" "us" ])
            (lib.gvariant.mkTuple [ "xkb" "latam" ])
          ];
        };

        "org/gnome/desktop/wm/keybindings" = {
          close = ["<Shift><Super>q"];
          toggle-fullscreen = ["<Super>F11"];
        };

        "org/gnome/mutter" = {
          overlay-key = "Super_L";
        };

        # org.gnome.desktop.interface clock-format 12h
        "org/gnome/desktop/interface" = {
          clock-format = "12h";
        };
      };
    }
  ];
}
