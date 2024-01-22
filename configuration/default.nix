{ config, lib, pkgs, inputs, wsl, mainUser, ... }:
{
  imports = [
    inputs.home.nixosModules.default
    inputs.nixos-wsl.nixosModules.default
    inputs.lanzaboote.nixosModules.lanzaboote
    ./base.nix
    ./hardware.nix
    ./network.nix
    ./nix.nix
    ./users.nix
    ./kernel.nix
    ./desktop.nix
  ]
  ++ lib.optional wsl ./wsl.nix
  ++ lib.optional (!wsl) ./filesystems.nix
  ++ lib.optional (mainUser == "luigi") ./luigi.nix
  ++ lib.optional (mainUser == "pietro") ./pietro.nix;

  system.stateVersion = "24.05";
  networking.hostName = "${if wsl then "wsl" else "linux"}g-${mainUser}";
}
