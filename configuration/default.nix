{ inputs, device, ... }: {
  imports = [
    inputs.home.nixosModules.default
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nix-ld.nixosModules.nix-ld
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix"
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

  isoImage.squashfsCompression = "zstd -Xcompression-level 22";

  system.stateVersion = "24.05";
  networking.hostName = "${{ "laptop" = "linux"; "desktop" = "tower"; }.${device}}g-luigi";
}
