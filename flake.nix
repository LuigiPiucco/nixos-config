{
  description = "Luigi's system config.";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://walker-git.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
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
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    walker.url = "github:abenz1267/walker";
    walker.inputs.nixpkgs.follows = "nixpkgs";
    iwmenu.url = "github:e-tho/iwmenu";
    iwmenu.inputs.nixpkgs.follows = "nixpkgs";
    bzmenu.url = "github:e-tho/bzmenu";
    bzmenu.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    let
      inherit (inputs.nixpkgs) lib;
      inherit (lib) nixosSystem;
      config = import ./configuration;
      pkgs = inputs.nixpkgs.legacyPackages;
      inputsPerArch = arch: lib.mapAttrs (_: input: lib.mapAttrs (_: attr:  attr.${arch} or attr) input) inputs;
      shellFunc = pkgs: {
        name = "config-luigi";
        buildInputs = with pkgs; [ nil nixfmt-rfc-style ];
      };
    in {
      inherit inputs;
      devShells.x86_64-linux.default = inputs.nixpkgs.legacyPackages.x86_64-linux.mkShell (shellFunc pkgs.x86_64-linux);
      devShells.aarch64-linux.default = inputs.nixpkgs.legacyPackages.aarch64-linux.mkShell (shellFunc pkgs.aarch64-linux);
      nixosConfigurations = let
        inherit lib;
        base-configs = {
          laptopg-luigi = {
            modules = [ config ];
            specialArgs = {
              inputs = inputsPerArch "x86_64-linux";
              device = "laptop";
              mainUser = "luigi";
              install-cd = false;
            };
            system = "x86_64-linux";
          };
          towerg-luigi = {
            modules = [ config ];
            specialArgs = {
              inputs = inputsPerArch "x86_64-linux";
              device = "desktop";
              mainUser = "luigi";
              install-cd = false;
            };
            system = "x86_64-linux";
          };
          rpi-luigi = {
            modules = [ config ];
            specialArgs = {
              inputs = inputsPerArch "aarch64-linux";
              device = "rpi";
              mainUser = "luigi";
              install-cd = false;
            };
            system = "aarch64-linux";
          };
        };
        install-configs =
          lib.mapAttrs' (name: value: {
            name = "${name}-install";
            value = lib.attrsets.updateManyAttrsByPath [{ path = ["specialArgs" "install-cd"]; update = old: !old; }] value;
          }) base-configs;
        wsl-configs.wslg-pietro = {
          modules = [ config ];
          specialArgs = {
            inputs = inputsPerArch "x86_64-linux";
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
