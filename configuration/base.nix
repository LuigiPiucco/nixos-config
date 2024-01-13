{ config, lib, pkgs, ... }:

{
  boot.tmp.cleanOnBoot = true;

  services.dbus.apparmor = "enabled";
  security.apparmor.enable = true;
  security.polkit.enable = true;
  security.sudo.wheelNeedsPassword = true;

  environment = {
    systemPackages = with pkgs; [
      binutils
      coreutils
      curl
      dnsutils
      bottom
      manix
      whois
      bat
      eza
      procs
      usbutils
      nix-direnv
      starship
      direnv
      fd
      git
      jq
      ripgrep
      python3
      libtool
      bat
      git-lfs
      zoxide
      man-pages
      stdmanpages
      tio
      socat
      ltex-ls
      p7zip
      xdg-dbus-proxy
      libsecret
    ];

    sessionVariables = {
      PAGER = "less";
      STARSHIP_CONFIG = ../data/starship.toml;
    };

    shellAliases = {
      top = "btm";
      nrb = "nixos-rebuild --use-remote-sudo";
      ctl = "systemctl";
      stl = "sudo systemctl";
      utl = "systemctl --user";
      jtl = "journalctl";
      ps = "procs";
    };
  };

  programs.nix-ld.enable = true;
  programs.command-not-found.enable = false;
  programs.ssh.enableAskPassword = false;
  programs.fish.enable = true;

  i18n = {
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "pt_BR.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
      "ja_JP.EUC-JP/EUC-JP"
    ];
    defaultLocale = "en_US.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us-acentos";
  };

  time = {
    timeZone = "America/Sao_Paulo";
    hardwareClockInLocalTime = true;
  };
}
