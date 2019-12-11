{ config, pkgs, ... }:

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
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.blacklistedKernelModules = ["efi_pstore"];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.logind.extraConfig = ''
    HandlePowerKey=hibernate
  '';

  boot.initrd.luks.devices = [
    { name = "root"; device = "/dev/sda2"; preLVM = true; allowDiscards = true; }
  ];

  networking.hostName = "grey-area";
  networking.firewall.enable = false;

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint pkgs.samsung-unified-linux-driver_1_00_37 ];

  programs.adb.enable = true;

  virtualisation.virtualbox.host.enable = true;

  system.stateVersion = "17.09"; # Did you read the comment?
}
