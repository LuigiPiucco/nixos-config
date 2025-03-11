{ pkgs, device, lib, ... }: {
  networking.enableIPv6 = true;
  networking.nftables.enable = true;
  networking.usePredictableInterfaceNames = true;
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
    enable = true;
    package = pkgs.bluez5;
    input.General = {
      UserspaceHID = true;
      ClassicBondedOnly = false;
    };
  };
  environment.systemPackages = with pkgs; [ obexfs ];

  programs.nm-applet.enable = true;
  services.resolved.enable = true;
  networking.wireless.iwd.enable = device != "laptop";
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    dhcp = "dhcpcd";
    insertNameservers = [ "1.1.1.1" "1.0.0.1" ];
    wifi = {
      powersave = true;
    } // lib.optionalAttrs (device != "laptop") {
      backend = "iwd";
    };
  };

  services.samba.enable = true;
  systemd.network.wait-online.enable = false;
}
