{ lib, device, ... }: {
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partlabel/nixos";
      fsType = "ext4";
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
  };
}
