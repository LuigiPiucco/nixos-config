{ lib, device, ... }: {
  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/nixos";
    fsType = "ext4";
  };
} // lib.optionalAttrs (device == "desktop") {
  fileSystems."~" = {
    device = "/dev/disk/by-partlabel/home-luigi";
    fsType = "ext4";
  };
  fileSystems."~/Games" = {
    device = "/dev/disk/by-partlabel/games-luigi";
    fsType = "ext4";
  };
}
