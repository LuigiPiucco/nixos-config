{ pkgs, device, ... }: {
  users.extraGroups.adbusers = { };
  users.extraGroups.plugdev = { };
  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;

  security.pam.mount = {
    enable = device == "desktop";
    extraVolumes = [
      ''<volume user="luigi" pgrp="users" path="/dev/disk/by-partlabel/home-luigi" mountpoint="~">''
      ''<volume user="luigi" pgrp="users" path="/dev/disk/by-partlabel/games-luigi" mountpoint="~/Games">''
    ];
    createMountPoints = true;
    removeCreatedMountPoints = true;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
