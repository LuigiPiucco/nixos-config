{ pkgs, lib, ... }: {
  # security.lockKernelModules = true;
  boot = {
    supportedFilesystems.zfs = lib.mkForce false;
    supportedFilesystems.fat = true;
    supportedFilesystems.ntfs-3g = true;

    kernelPackages = pkgs.linuxKernel.packages.linux_zen;

    initrd.enable = true;
  };
}
