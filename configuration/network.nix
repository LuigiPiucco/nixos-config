{ config, lib, pkgs, ... }:

{
  networking.firewall.enable = false;
  networking.nftables.enable = false;
  networking.hostName = "WSLG-LUIGI";
}
