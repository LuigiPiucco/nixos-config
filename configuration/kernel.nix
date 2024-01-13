{ config, pkgs, inputs, ... }:
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
      pkgs.linuxPackagesFor wsl-kernel;
    kernelModules = ["ftdi_sio" "usbserial" "usbcore" "ch9344" "usbip"];
  };
  environment.systemPackages = [
    config.boot.kernelPackages.usbip
  ];
}
