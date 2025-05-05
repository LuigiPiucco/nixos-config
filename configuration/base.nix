{ pkgs, lib, device, mainUser, inputs, ... }:
{
  boot.tmp.cleanOnBoot = false;
  systemd.tmpfiles.rules = ["D! /tmp 1777 root root 0d"];

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
      helix
      pijul
      pciutils
      sbctl
      zstd
      unrar
      binutils
      coreutils
      curl
      wget
      unzip
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
      python3
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

  programs.nix-ld.dev = {
    libraries = with pkgs; [
      libGL
      libusb1
      libftdi1
      stdenv.cc.libc
      stdenv.cc.cc
      zlib
      e2fsprogs
      libgpg-error
      xorg.libX11
      libsForQt5.qt5.qtwayland
    ];
    enable = true;
  };
  programs.command-not-found.enable = false;
  programs.ssh.enableAskPassword = false;


  documentation = {
    dev.enable = true;
    man.enable = true;
    doc.enable = true;
    info.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  i18n = {
    supportedLocales =
      [ "en_US.UTF-8/UTF-8" "pt_BR.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8" ];
    defaultLocale = {
      "luigi" = "en_US.UTF-8";
      "pietro" = "pt_BR.UTF-8";
    }.${mainUser};
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  time = {
    timeZone = "America/Sao_Paulo";
    hardwareClockInLocalTime = true;
  };

  programs.usbtop.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
    enableSSHSupport = true;
    enableExtraSocket = true;
    enableBrowserSocket = true;
  };

  wsl = {
    enable = device == "wsl";
    defaultUser = "pietro";
    usbip.enable = true;
    wslConf.network.generateResolvConf = false;
    tarball.configPath = inputs.self;
  };
} // lib.optionalAttrs (device != "wsl") {
  services.syncthing = {
    enable = true;
    overrideDevices = false;
    overrideFolders = false;
  };
  services.fwupd.enable = true;
  services.udisks2.enable = true;

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    # enrollKeys = true;
    configurationLimit = 3;
  };

  programs.corectrl = {
    enable = true;
    gpuOverclock = {
      enable = true;
      ppfeaturemask = "0xffffffff";
    };
  };

}
