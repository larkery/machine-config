{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./common.nix
      ./shell.nix
      ./packages.nix
      ./trackpoint.nix
      ./autofs.nix
      ./sysctls.nix
      ./syncthing.nix
      ./pulseaudio.nix
      ./kernel-ck.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.blacklistedKernelModules = ["efi_pstore"];

  services.logind.extraConfig = ''
    HandlePowerKey=hibernate
  '';

  boot.initrd.luks.devices = [
    { name = "root"; device = "/dev/sda2"; preLVM = true; allowDiscards = true; }
  ];

  networking.hostName = "grey-area";
  networking.firewall.enable = false;

  programs.adb.enable = true;

  virtualisation.virtualbox.host.enable = true;

  system.stateVersion = "17.09"; # Did you read the comment?
}
