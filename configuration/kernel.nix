{ pkgs, ... }: {
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
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
      enable = true;
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
}
