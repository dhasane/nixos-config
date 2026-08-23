{ ... }:

{
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      # `nixos-rebuild` auto-picks nixosConfigurations.<currentHostname>
      # from the flake — the same alias works on every machine.
      update = "sudo nixos-rebuild switch --flake /etc/nixos";
    };
    # history = {
    #   size = 10000;
    #   # path = "${config.xdg.dataHome}/zsh/history";
    # };
  };
}
