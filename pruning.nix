{ config, pkgs, vars, ... }:

{
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.optimise.automatic = true;

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

  # Prune old user + home-manager profile generations so nix-gc can reclaim them.
  systemd.services.nix-prune-user-generations-weekly = {
    description = "Prune per-user Nix and home-manager profile generations older than 7 days";
    serviceConfig = {
      Type = "oneshot";
      User = vars.username;
    };
    script = ''
      for profile in \
        /nix/var/nix/profiles/per-user/${vars.username}/profile \
        /nix/var/nix/profiles/per-user/${vars.username}/home-manager \
        /nix/var/nix/profiles/per-user/${vars.username}/channels; do
        [ -e "$profile" ] && ${pkgs.nix}/bin/nix-env --profile "$profile" --delete-generations +3 || true
      done
    '';
  };

  systemd.timers.nix-prune-user-generations-weekly = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
