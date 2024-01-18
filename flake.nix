{
  description = "Luigi's system config.";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    home.url = "github:nix-community/home-manager";
    home.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";

    microsoft-kernel = { url = "github:microsoft/WSL2-Linux-Kernel/linux-msft-wsl-6.1.y"; flake = false; };
  };

  outputs = inputs: let
    inherit (inputs.nixpkgs.lib) nixosSystem;
    config = import ./configuration;
  in {
    inherit inputs;
    nixosConfigurations = {
      wslg-pietro = nixosSystem {
        modules = [config];
        specialArgs = {inherit inputs; wsl = true; mainUser = "pietro";};
        system = "x86_64-linux";
      };
      wslg-luigi = nixosSystem {
        modules = [config];
        specialArgs = {inherit inputs; wsl = true; mainUser = "luigi";};
        system = "x86_64-linux";
      };
      linuxg-luigi = nixosSystem {
        modules = [config];
        specialArgs = {inherit inputs; wsl = false; mainUser = "luigi";};
        system = "x86_64-linux";
      };
    };
  };
}
