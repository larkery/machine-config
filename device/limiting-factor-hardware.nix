# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" "sdhci_pci" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8eddda36-9051-44d2-9fd5-51e74d669a15";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/4DDC-2EE0";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/c103c804-5ec9-4646-adf6-52717a086105"; }
    ];

  nix.maxJobs = lib.mkDefault 4;
}
