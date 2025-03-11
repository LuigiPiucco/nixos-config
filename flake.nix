{
  description = "Luigi's system config.";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
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
    hyprland.url = "github:hyprwm/Hyprland";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
  };

  outputs = inputs:
    let
      inherit (inputs.nixpkgs.lib) nixosSystem;
      config = import ./configuration;
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    in {
      inputs = pkgs.lib.mapAttrs (_: input: pkgs.lib.mapAttrs (_: attr:  attr.x86_64-linux or attr) input) inputs;
      devShells.x86_64-linux.default = pkgs.mkShell {
        name = "config-luigi";
        buildInputs = with pkgs; [ nil nixfmt-rfc-style ];
      };
      nixosConfigurations = let
        inherit (pkgs) lib;
        base-configs = {
          laptopg-luigi = {
            modules = [ config ];
            specialArgs = {
              inherit inputs;
              device = "laptop";
              mainUser = "luigi";
            };
            system = "x86_64-linux";
          };
          towerg-luigi = {
            modules = [ config ];
            specialArgs = {
              inherit inputs;
              device = "desktop";
              mainUser = "luigi";
              install-cd = false;
            };
            system = "x86_64-linux";
          };
        };
        install-configs =
          pkgs.lib.mapAttrs' (name: value: {
            name = "${name}-install";
            value = lib.attrsets.updateManyAttrsByPath [{ path = ["specialArgs" "install-cd"]; update = old: !old; }] value;
          }) base-configs;
        wsl-configs.wslg-pietro = {
          modules = [ config ];
          specialArgs = {
            inherit inputs;
            device = "wsl";
            mainUser = "pietro";
            install-cd = false;
          };
          system = "x86_64-linux";
        };
        all-configs = base-configs // install-configs // wsl-configs;
      in lib.mapAttrs (_: conf: nixosSystem conf) all-configs;
    };
}
