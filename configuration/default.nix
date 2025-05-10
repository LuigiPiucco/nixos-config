{ inputs, device, lib, install-cd, mainUser, ... }: {
  imports = [
    inputs.home.nixosModules.default
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nix-ld.nixosModules.nix-ld
    inputs.hyprland.nixosModules.default
    inputs.nixos-wsl.nixosModules.default
    ./kernel.nix
    ./hardware.nix
    ./base.nix
    ./network.nix
    ./nix.nix
    ./users.nix
    ./filesystems.nix
    ./desktop.nix
    ./${mainUser}.nix
  ] ++ lib.optional (install-cd && device != "rpi") "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix"
  ++ lib.optionals (device == "rpi") [ "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" inputs.nixos-hardware.nixosModules.raspberry-pi-4 ];

  system.stateVersion = "25.05";
  networking.hostName = "${{ "laptop" = "linuxg"; "desktop" = "towerg"; "wsl" = "wslg"; "rpi" = "rpi"; }.${device}}-${mainUser}";
} // lib.optionalAttrs (install-cd && device != "rpi") {
  isoImage.squashfsCompression = "zstd -Xcompression-level 22";
} // lib.optionalAttrs (device == "rpi") {
  nixpkgs.hostPlatform.system = "aarch64-linux";
} // lib.optionalAttrs (device == "rpi" && install-cd) {
  nixpkgs.buildPlatform.system = "x86_64-linux";
}
