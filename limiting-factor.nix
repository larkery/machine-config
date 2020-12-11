{ config, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      
      ./home
      ./common.nix
      ./shell.nix
      ./packages.nix
      ./trackpoint.nix
      ./sysctls.nix
      ./syncthing.nix
      ./pulseaudio.nix
      ./vpn.nix
      ./printing.nix
    ];


    # hack for autologin https://github.com/NixOS/nixpkgs/issues/97795
    systemd.services.display-manager.wants = [ "systemd-user-sessions.service" "multi-user.target" "network-online.target" ];
    systemd.services.display-manager.after = [ "systemd-user-sessions.service" "multi-user.target" "network-online.target" ];

    
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.timeout = 1;
    boot.blacklistedKernelModules = ["efi_pstore"];

    hardware.bluetooth.enable = true;
    hardware.bluetooth.package = pkgs.bluezFull;

    hardware.opengl.driSupport32Bit = true;
    
    boot.cleanTmpDir = true;

    systemd.tmpfiles.rules = [
      "d /tmp 1777 root root 10d"
    ];

    virtualisation.virtualbox.host.enable = true;

    hardware.pulseaudio.zeroconf.discovery.enable = true;

    boot.initrd.luks.devices = {
      root = { device = "/dev/sda2"; preLVM = true; allowDiscards = true; };
    };

    powerManagement.powerUpCommands = ''
      export PATH="$PATH:${pkgs.emacs}/bin"
      emacsclient -n -e '(tramp-cleanup-all-connections)' -s /tmp/emacs1000/server
    '';
    
    networking.hostName = "limiting-factor";
    networking.domain = "cse.org.uk";
    networking.search = ["cse.org.uk"];
    networking.firewall.enable = false;
    
    networking.extraHosts = ''
      62.232.139.117 buzz.cse.org.uk buzz
    '';

    documentation.man.generateCaches = true;
    
    #services.dbus.packages = [pkgs.gcr];

    services.udev.extraRules =
      let 
      power-usb-device = pkgs.writeShellScript "usb-power" ''
        #!${pkgs.bash}/bin/bash

        vendor=$1
        product=$2
        mode=$3
        grep=${pkgs.gnugrep}/bin/grep
        find=${pkgs.findutils}/bin/find
        
        path=$($find /sys/bus/usb/devices -maxdepth 1 -exec $grep -s -q 04f2 '{}/idVendor' ';' -exec $grep -s -q b2ea '{}/idProduct' ';' -print)

        if [[ -e $path ]] ; then
           echo $mode > $path/bConfigurationValue
        fi
      '';
      in
      ''
        ACTION=="add", SUBSYSTEM=="usb", ENV{PRODUCT}=="1415/2000/200", RUN+="${power-usb-device} 04f2 b2ea 0"

        ACTION=="remove", SUBSYSTEM=="usb", ENV{PRODUCT}=="1415/2000/200", RUN+="${power-usb-device} 04f2 b2ea 1"
      '';
    
      system.stateVersion = "17.09";


}
