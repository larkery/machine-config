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
      ./kernel-ck.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.blacklistedKernelModules = ["efi_pstore"];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluezFull;

  services.printing.enable = true;
  boot.cleanTmpDir = true;

  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root 10d"
  ];

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
  
  networking.extraHosts = ''
  62.232.139.117 buzz.cse.org.uk buzz
  '';

  services.udev.extraRules = ''
    ACTION=="remove", GOTO="co2mini_end"

    SUBSYSTEMS=="usb", KERNEL=="hidraw*", ATTRS{idVendor}=="04d9", ATTRS{idProduct}=="a052", GROUP="users", MODE="0660", SYMLINK+="co2mini%n", GOTO="co2mini_end"

    LABEL="co2mini_end"
  '';
  
  system.stateVersion = "17.09";

  systemd.services.arandrWake =
    let targets = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
    in {
    enable = true;
    wantedBy = targets;
    script = ''
      export DISPLAY=:0
      sleep 1
      ${pkgs.autorandr}/bin/autorandr -c
    '';
    after = targets;
    serviceConfig = { User = "hinton"; };
  };
}
