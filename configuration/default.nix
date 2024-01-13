inputs: { config, lib, pkgs, ... }:
{
  _module.args = { inherit inputs; };
  imports = [
    inputs.home.nixosModules.default
    inputs.nixos-wsl.nixosModules.default
    ./desktop.nix
    ./hardware.nix
    ./kernel.nix
    ./network.nix
    ./nix.nix
    ./users.nix
    ./wsl.nix
  ];
  system.stateVersion = "24.05";
  nixpkgs.overlays = [
    inputs.emacs-overlay.overlays.default
  ];
}
