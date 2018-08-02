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

  powerManagement.powerUpCommands = ''
  ${pkgs.emacs}/bin/emacsclient -n -e '(progn (message "Cleanup connections") (tramp-cleanup-all-connections))' -s /tmp/emacs1000/server
  '';

  networking.hostName = "limiting-factor";
  networking.domain = "cse.org.uk";
  networking.wireless.enable = true;
  networking.firewall.enable = false;
  networking.extraHosts = ''
  62.232.139.117 buzz.cse.org.uk buzz
  '';


  services.udev.extraRules = ''
    ACTION=="remove", GOTO="co2mini_end"

    SUBSYSTEMS=="usb", KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a052", GROUP="users", MODE="0660", SYMLINK+="co2mini%n", GOTO="co2mini_end"

    LABEL="co2mini_end"
  '';
  
  system.stateVersion = "17.09";
}
