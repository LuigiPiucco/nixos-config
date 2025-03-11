{ pkgs, device, install-cd, lib, ... }: {
  users.extraGroups.adbusers = { };
  users.extraGroups.plugdev = { };

  programs.fish.enable = true;

  security.pam.mount = {
    enable = device == "desktop";
    extraVolumes = [
      ''<volume user="luigi" pgrp="users" path="/dev/disk/by-partlabel/games-luigi" mountpoint="~/Games" />''
    ];
    createMountPoints = true;
    removeCreatedMountPoints = true;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
} // lib.optionalAttrs (!install-cd && device != "wsl") {
  users.users.root.hashedPassword = "$6$AuFJcsrir3QGAuqD$XavJkb/EsihqfAZLX86USxjX/i9mxRNiDi.e36vNSwKIsSjY9XbyBrVwwgR37X2uSrbpeWSbmBvOcnv2podCM/";
} // lib.optionalAttrs (device != "wsl") {
  users.defaultUserShell = pkgs.fish;
} // lib.optionalAttrs (device == "wsl") {
  users.users.root.password = "nopassword";
}
