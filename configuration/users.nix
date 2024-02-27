{ config, pkgs, inputs, ... }:

{
  users.extraGroups.adbusers = {};
  users.extraGroups.plugdev = {};
  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
