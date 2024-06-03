{ lib, dev ? "/dev/nvme0n1", ... }:
{
  disk.nixos = {
    device = dev;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        nixos = {
          start = ""; # Makes this partition start immediately after the previous one.
          end = "-32G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
        swap = {
          size = "100%";
          content = {
            type = "swap";
            randomEncryption = true;
          };
        };
      };
    };
  };
}