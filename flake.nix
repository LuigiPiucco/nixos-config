{
  description = "Luigi's system config.";

  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    home.url = "github:nix-community/home-manager";
    home.inputs.nixpkgs.follows = "nixpkgs";
    nix-ld.url = "github:nix-community/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = inputs:
    let
      inherit (inputs.nixpkgs.lib) nixosSystem;
      config = import ./configuration;
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    in {
      inputs = pkgs.lib.mapAttrs (_: input: pkgs.lib.mapAttrs (_: attr:  attr.x86_64-linux or attr) input) inputs;
      devShells.x86_64-linux.default = pkgs.mkShell {
        name = "linuxg-luigi";
        buildInputs = with pkgs; [ nil nixfmt ];
      };
      nixosConfigurations = {
        linuxg-luigi = nixosSystem {
          modules = [ config ];
          specialArgs = {
            inherit inputs;
            mainUser = "luigi";
          };
          system = "x86_64-linux";
        };
      };
    };
}
