{minimal, ...}@inputs: { config, lib, pkgs, ... }:
{
  _module.args = { inherit inputs; };
  imports = [
    inputs.home.nixosModules.default
    inputs.nixos-wsl.nixosModules.default
    ../base.nix
    ../hardware.nix
    ../network.nix
    ../nix.nix
    ../users.nix
    ../wsl.nix
    ../kernel.nix
    ../pietro.nix
  ] ++ lib.optionals (!minimal) [
    ../desktop.nix
  ];

  system.stateVersion = "24.05";
  nixpkgs.overlays = [
    inputs.emacs-overlay.overlays.default
  ];

  networking.hostName = "WSLG-PIETRO";
}
