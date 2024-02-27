{ config, lib, pkgs, wsl, ... }:

{
  networking.enableIPv6 = true;
  networking.firewall.enable = !wsl;
  networking.nameservers = ["1.1.1.1" "1.0.0.1"];
  networking.useNetworkd = true;
  networking.dhcpcd.enable = false;
  networking.tcpcrypt.enable = true;
  networking.usePredictableInterfaceNames = true;

  networking.nftables.enable = !wsl;
  networking.nftables.tables = {
    filter = {
      family = "inet";
      content = ''
        chain input {
          type filter hook input priority 0;

          iifname lo accept;

          ct state {established, related} accept

          ip6 nexthdr icmpv6 icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept
          ip protocol icmp icmp type { destination-unreachable, router-advertisement, time-exceeded, parameter-problem } accept

          ip6 nexthdr icmpv6 icmpv6 type echo-request accept
          ip protocol icmp icmp type echo-request accept

          tcp dport 22 accept

          counter drop
        }

        chain output {
          type filter hook output priority 0;
          accept
        }
      '';
    };
  };

  hardware.bluetooth = {
    enable = !wsl;
    package = pkgs.bluez5;
    input.General = {
      UserspaceHID = true;
      ClassicBondedOnly = false;
    };
  };

  users.users.tcpcryptd.group = "tcpcryptd";
  users.groups.tcpcryptd = {};

  networking.wireless.iwd.enable = !wsl;
  networking.networkmanager = {
    enable = !wsl;
    dns = "systemd-resolved";
    wifi = {
      backend = "iwd";
      powersave = true;
    };
  };

  systemd.network.wait-online.enable = false;
  systemd.services.systemd-resolved.enable = true;
}
