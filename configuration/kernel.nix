{ lib, config, pkgs, inputs, wsl, ... }:
{
  boot = {
    kernelPackages = let
      msconfig = pkgs.writeTextFile {
        name = "config-wsl";
        text = ''
          ${builtins.readFile "${inputs.microsoft-kernel}/Microsoft/config-wsl"}

          CONFIG_SERIAL_DEV_BUS=y
          CONFIG_USB_SERIAL_CONSOLE=y
          CONFIG_USB_SERIAL_GENERIC=y
          CONFIG_USB_SERIAL_SIMPLE=y
        '';
      };
      wsl-kernel = pkgs.linuxManualConfig {
        version = "6.1.21";
        modDirVersion = "6.1.21.2-microsoft-standard-WSL2";
        configfile = msconfig;
        extraMeta.branch = "linux-msft-wsl-6.1.y";
        src = inputs.microsoft-kernel;
        kernelPatches = [];
      };
    in
      if wsl then pkgs.linuxPackagesFor wsl-kernel else pkgs.linuxKernel.packages.linux_zen;
    kernelModules = [
      "kvm-intel"
      "btusb"
      "ftdi_sio"
      "usbserial"
      "usbcore"
      "ch9344"
      "usbip"
      "apfs"
      "hid-ite8291r3"
      "hid-playstation"
      "hid-generic"
      "pkcs8-key-parser"
    ];

    initrd = {
      enable = !wsl;
      availableKernelModules = [
        "xhci_pci"
        "dwc3_pci"
        "ahci"
        "nvme"
        "usbhid"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      kernelModules = [ ];
    };
  };
  environment.systemPackages = lib.optional wsl config.boot.kernelPackages.usbip;
}
