{
  description = "Luigi's system config.";

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
