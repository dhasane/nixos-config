{ ... }:

{
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
}
