{ pkgs, ... }:
{
  boot.tmp.cleanOnBoot = false;
  systemd.tmpfiles.rules = ["D! /tmp 1777 root root 0d"];

  security.lockKernelModules = true;
  services.dbus = {
    apparmor = "enabled";
    implementation = "broker";
  };
  security.apparmor = {
    enable = true;
    killUnconfinedConfinables = true;
  };
  security.polkit.enable = true;
  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = true;

  environment = {
    systemPackages = with pkgs; [
      pijul
      pciutils
      sbctl
      zstd
      unrar
      binutils
      coreutils
      curl
      dnsutils
      bottom
      manix
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
      ripgrep
      bat
      git-lfs
      zoxide
      man-pages
      stdmanpages
      socat
      ltex-ls
      p7zip
      xdg-dbus-proxy
      libsecret
      wineWowPackages.stagingFull
      dxvk
      vkd3d
      vkd3d-proton
    ];

    sessionVariables = { PAGER = "less"; };

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

  programs.nix-ld.dev.enable = true;
  programs.command-not-found.enable = false;
  programs.ssh.enableAskPassword = false;

  nixpkgs.config.allowUnfree = true;

  i18n = {
    supportedLocales =
      [ "en_US.UTF-8/UTF-8" "pt_BR.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8" ];
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

  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  programs.usbtop.enable = true;

  programs.corectrl = {
    enable = true;
    gpuOverclock = {
      enable = true;
      ppfeaturemask = "0xffffffff";
    };
  };

  boot.loader.systemd-boot.editor = false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  services.fwupd.enable = true;
  services.udisks2.enable = true;
  services.syncthing = {
    enable = true;
    overrideDevices = false;
    overrideFolders = false;
  };
}
