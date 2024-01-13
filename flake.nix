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
    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = inputs: {
    nixosConfigurations.x86_64-linux.WSLG-LUIGI = import ./configuration inputs;
  };
}
