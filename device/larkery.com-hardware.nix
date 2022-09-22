{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ];

  boot.initrd.availableKernelModules = [ "virtio_pci" "ahci" "sd_mod" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/sda";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/sdb"; }
    ];

  nix.maxJobs = lib.mkDefault 1;
}
