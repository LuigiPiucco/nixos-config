{ config, pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_5_15;
    kernelModules = ["ftdi_sio" "usbserial" "usbcore" "ch9344" "usbip"];
  };
  environment.systemPackages = [
    config.boot.kernelPackages.usbip
  ];
}
