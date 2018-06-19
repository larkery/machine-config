{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./common.nix
      ./trackpoint.nix
      ./autofs.nix
      ./sysctls.nix
      ./syncthing.nix
      ./pulseaudio.nix
    ];


  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
#  boot.kernelPackages = pkgs.linuxPackages_latest; appears broken for wifi?

  #programs.adb.enable = true;

  virtualisation.virtualbox.host.enable = true;

  hardware.pulseaudio.zeroconf.discovery.enable = true;

  boot.initrd.luks.devices = [
    { name = "root"; device = "/dev/sda2"; preLVM = true; allowDiscards = true; }
  ];

  networking.hostName = "limiting-factor";
  networking.domain = "cse.org.uk";
  networking.wireless.enable = true;
  networking.firewall.enable = false;

  services.udev.extraRules = ''
    ACTION=="remove", GOTO="co2mini_end"

    SUBSYSTEMS=="usb", KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a052", GROUP="users", MODE="0660", SYMLINK+="co2mini%n", GOTO="co2mini_end"

    LABEL="co2mini_end"
  '';
  
  system.stateVersion = "17.09";
}
