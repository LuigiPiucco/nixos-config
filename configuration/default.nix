inputs: { config, lib, pkgs, ... }:
{
  _module.args = { inherit inputs; };
  imports = [
    inputs.home.nixosModules.x86_64-linux.default
    inputs.nixos-wsl.nixosModules.x86_64-linux.default
    ./desktop.nix
    ./desktop.nix
    ./hardware.nix
    ./kernel.nix
    ./network.nix
    ./nix.nix
    ./wsl.nix
  ];
  system.stateVersion = "23.05";
}
