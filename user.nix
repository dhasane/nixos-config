{ pkgs, vars, ... }:

let
  username = vars.username;
in
{
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    description = vars.fullName;
    shell = pkgs.zsh;
    packages = with pkgs; [
    #  thunderbird
    ];
  };
}
