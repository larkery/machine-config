{ config, pkgs, ... }:
{
  imports =
    [ ./hardware-configuration.nix
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

  virtualisation.virtualbox.host.enable = true;

  hardware.pulseaudio.zeroconf.discovery.enable = true;

  boot.initrd.luks.devices = [
    { name = "root"; device = "/dev/sda2"; preLVM = true; allowDiscards = true; }
  ];

  powerManagement.powerUpCommands = ''
    export PATH="$PATH:${pkgs.emacs}/bin"
    emacsclient -n -e '(tramp-cleanup-all-connections)' -s /tmp/emacs1000/server
  '';

  networking.hostName = "limiting-factor";
  networking.domain = "cse.org.uk";
  networking.search = ["cse.org.uk"];
  networking.firewall.enable = false;
  networking.networkmanager.enable = true;
  networking.networkmanager.dhcp = "internal";
  programs.firejail.enable = true;

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
