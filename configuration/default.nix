{ inputs, device, lib, install-cd, mainUser, ... }: {
  imports = [
    inputs.home.nixosModules.default
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nix-ld.nixosModules.nix-ld
    inputs.hyprland.nixosModules.default
    inputs.nixos-wsl.nixosModules.default
    ./base.nix
    ./hardware.nix
    ./network.nix
    ./nix.nix
    ./users.nix
    ./${mainUser}.nix
  ]
  ++ lib.optional install-cd "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix"
  ++ lib.optional (device == "rpi") "${inputs.nixos-hardware}/raspberry-pi/4"
  ++ lib.optionals (device != "wsl") [ ./desktop.nix ./kernel.nix  ./filesystems.nix ];

  system.stateVersion = "25.05";
  networking.hostName = "${{ "laptop" = "linux"; "desktop" = "tower"; "wsl" = "wsl"; }.${device}}g-${mainUser}";
} // lib.optionalAttrs install-cd {
  isoImage.squashfsCompression = "zstd -Xcompression-level 22";
}
