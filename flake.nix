{
  description = "NixOS configuration for the Latitude 5420";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Personal home-manager config (a git repo, not a flake). Its home.nix
    # is imported by user/home-manager.nix via specialArgs. Uncommitted
    # changes are NOT visible — commit inside the myhome repo before rebuild.
    myhome = {
      url = "git+file:///home/vestigo/.config/home-manager";
      flake = false;
    };

    # Secure Boot support (see system/lanzaboote.nix).
    # Bump the version tag when new releases are cut:
    # https://github.com/nix-community/lanzaboote/releases
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, myhome, ... }:
    let
      mkHost = name: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          vars = import ./hosts/${name}/identity.nix;
          inherit myhome;
        };
        modules = [
          ./hosts/${name}
          home-manager.nixosModules.home-manager
          lanzaboote.nixosModules.lanzaboote
        ];
      };
    in
    {
      nixosConfigurations = {
        nixos = mkHost "nixos";
      };
    };
}
