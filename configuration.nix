{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./common.nix
      ./trackpoint.nix
      ./autofs.nix
      ./ppp.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;

  boot.initrd.luks.devices = [
    { name = "root"; device = "/dev/sda2"; preLVM = true; allowDiscards = true; }
  ];

  networking.hostName = "grey-area";
  networking.wireless.enable = true;
  networking.firewall.enable = false;

  services.ppp = {
    enable = true;
    config = {
      cse = {
        defaultroute = false;
        host = "webmail.cse.org.uk";
        username = "tomh";
        usepeerdns = true;
        refuse-eap = true;
        mtu=800;
        routes = [ "10.0.0.0/8" "172.16.10.2/24" ];
      };
    };
  };

  hardware.pulseaudio = {
    zeroconf.discovery.enable = true;
    enable = true;
    support32Bit = true;
    package = pkgs.pulseaudioFull.overrideAttrs (oldAttrs : rec {
      version = "11.0";
      src = pkgs.fetchurl {
        url = "http://freedesktop.org/software/pulseaudio/releases/pulseaudio-${version}.tar.xz";
        sha256 = "0sf92knqkvqmfhrbz4vlsagzqlps72wycpmln5dygicg07a0a8q7";
      };
    });
  };

  services.syncthing = {
    enable = true;
    dataDir = "/home/hinton/.config/syncthing";
    user = "hinton";
    group = "users";
  };

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint pkgs.samsung-unified-linux-driver_1_00_37 ];

  programs.adb.enable = true;

  virtualisation.virtualbox.host.enable = true;

  system.stateVersion = "17.09"; # Did you read the comment?
}
