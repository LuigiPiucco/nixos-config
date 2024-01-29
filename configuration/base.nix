{ config, lib, pkgs, wsl, ... }:

{
  boot.tmp.cleanOnBoot = true;

  security.lockKernelModules = true;
  services.dbus.apparmor = "enabled";
  security.apparmor = {
    enable = true;
    killUnconfinedConfinables = true;
  };
  security.polkit.enable = true;
  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = true;

  environment = {
    systemPackages = with pkgs; [
      pciutils
      sbctl
      zstd
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
      ntfs3g
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

  nixpkgs.config.allowUnfree = true;

  i18n = {
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "pt_BR.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];
    defaultLocale = "en_US.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  time = {
    timeZone = "America/Sao_Paulo";
    hardwareClockInLocalTime = true;
  };

  boot.initrd.enable = false;
} // lib.optionalAttrs (!wsl) {
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableAllFirmware = true;

  boot.loader.systemd-boot.editor = false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  services.fwupd.enable = true;
  services.udisks2.enable = true;
}
