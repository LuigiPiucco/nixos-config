{ inputs, mainUser, ... }: {
  imports = [
    inputs.home.nixosModules.default
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nix-ld.nixosModules.nix-ld
    ./base.nix
    ./hardware.nix
    ./network.nix
    ./nix.nix
    ./users.nix
    ./kernel.nix
    ./desktop.nix
    ./filesystems.nix
    ./luigi.nix
  ];

  system.stateVersion = "24.05";
  networking.hostName = "linuxg-${mainUser}";
}
