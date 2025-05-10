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
      pciutils
      zstd
      unrar
      binutils
      coreutils
      curl
      wget
      unzip
      dnsutils
      bottom
      bat
      eza
      procs
      usbutils
      nix-direnv
      starship
      direnv
      fd
      git
      ripgrep
      bat
      git-lfs
      zoxide
      socat
      ltex-ls
      p7zip
      xdg-dbus-proxy
      libsecret
      python3
    ] ++ lib.optionals (device != "rpi") [
      manix
      man-pages
      stdmanpages
      helix
      pijul
      sbctl
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
      zlib
      e2fsprogs
      libgpg-error
    ];
    enable = true;
  };
  programs.command-not-found.enable = false;
  programs.ssh.enableAskPassword = false;

  documentation = {
    dev.enable  = device != "rpi";
    man.enable  = device != "rpi";
    doc.enable  = device != "rpi";
    info.enable = device != "rpi";
  };

  nixpkgs.config.allowUnfree = true;

  i18n = {
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "pt_BR.UTF-8/UTF-8"
    ] ++ lib.optional (mainUser == "luigi" && device != "rpi") "ja_JP.UTF-8/UTF-8";
    defaultLocale = {
      "luigi" = "en_US.UTF-8";
      "pietro" = "pt_BR.UTF-8";
    }.${mainUser};
  };

  console = {
    enable = true;
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  time = {
    timeZone = "America/Sao_Paulo";
    hardwareClockInLocalTime = true;
  };

  programs.usbtop.enable = device != "rpi";

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

  boot.loader.systemd-boot.editor = false;

  services.udisks2.enable = true;

  environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];
} // lib.optionalAttrs (device != "wsl" && device != "rpi") {
  services.syncthing = {
    enable = true;
    overrideDevices = false;
    overrideFolders = false;
  };
  services.fwupd.enable = true;
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
