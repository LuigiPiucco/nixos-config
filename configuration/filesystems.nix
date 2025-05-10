{ lib, device, ... }: lib.optionalAttrs (device != "wsl") {
  fileSystems = {
    "/" = {
      device = if device != "rpi"
               then "/dev/disk/by-partlabel/nixos"
               else "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    } // lib.optionalAttrs (device == "rpi") {
      options = ["noatime"];
    };
  } // lib.optionalAttrs (device == "desktop") {
    "/boot" = {
      device = "/dev/sda1";
      fsType = "vfat";
      mountPoint = "/boot";
    };
    "/home/luigi" = {
      device = "/dev/disk/by-partlabel/home-luigi";
      fsType = "ext4";
    };
  } // lib.optionalAttrs (device == "rpi") {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      mountPoint = "/boot/firmware";
    };
  };
}
