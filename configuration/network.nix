{ config, lib, pkgs, ... }:

{
  networking.firewall.enable = false;
  networking.nftables.enable = false;
  networking.nameservers = ["1.1.1.1" "1.0.0.1"];

  systemd.services.systemd-resolved.enable = true;
}
