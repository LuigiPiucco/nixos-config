{ config, pkgs, inputs, ... }:

{
  users.extraGroups.plugdev = {};
  users.defaultUserShell = pkgs.fish;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
}
