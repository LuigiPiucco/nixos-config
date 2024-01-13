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

    microsoft-kernel = { url = "github:microsoft/WSL2-Linux-Kernel/linux-msft-wsl-6.1.y"; flake = false; };
  };

  outputs = inputs: let
    nixos = import "${inputs.nixpkgs}/nixos";
    minargs = inputs // {minimal = true;};
    maxargs = inputs // {minimal = false;};
  in {
    inherit inputs;
    nixosConfigurations = {
      WSLG-LUIGI = nixos {
        configuration = import ./configuration/wslg-luigi maxargs;
        system = "x86_64-linux";
      };
      WSLG-PIETRO = nixos {
        configuration = import ./configuration/wslg-pietro maxargs;
        system = "x86_64-linux";
      };
      WSL-LUIGI = nixos {
        configuration = import ./configuration/wslg-luigi minargs;
        system = "x86_64-linux";
      };
      WSL-PIETRO = nixos {
        configuration = import ./configuration/wslg-pietro minargs;
        system = "x86_64-linux";
      };
    };
  };
}
