{ pkgs, lib, device, ... }: let
  rpi-overlay = _: prev: {
    makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });
  };
in
{
  # security.lockKernelModules = true;
  boot = {
    supportedFilesystems.zfs = lib.mkForce false;
    supportedFilesystems.fat = true;
    supportedFilesystems.ntfs-3g = device != "rpi";

    initrd.enable = true;
  } // lib.optionalAttrs (device == "desktop") {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  } // lib.optionalAttrs (device != "rpi") {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  } // lib.optionalAttrs (device == "rpi") {
    kernelParams = [ "snd_bcm2835.enable_hdmi=1" "snd_bcm2835.enable_headphones=1" ];
    kernelPackages = pkgs.linuxPackages_rpi4;
  };
  nixpkgs.overlays = lib.optional (device == "rpi") rpi-overlay;
}
