{config, pkgs, ...} : {
  imports = [
    ./limiting-factor-hardware.nix
    ./printing.nix
    ./vpn.nix
    ../graphical
    ../console
  ];

  powerManagement.enable = true;
  services.tlp.enable = true;
  
  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';
  
  boot.initrd.luks.devices.root = {
    device = "/dev/sda2";
    preLVM = true;
    allowDiscards = true; 
  };
  
  networking.hostName = "limiting-factor";
  networking.domain = "cse.org.uk";
  networking.search = ["cse.org.uk"];
  networking.firewall.enable = false;
  
  networking.extraHosts = ''
    62.232.139.117 buzz.cse.org.uk buzz
  '';

  ## x230 specific junk
  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
    intel-media-driver
  ];
  
  boot.kernelModules = ["acpi_call" "tpm-rng"];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  ## s-drive
  fileSystems."/net/S" = {
    device = "//cse-bs3-data.cse.org.uk/data";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "noauto,x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=2,x-systemd.mount-timeout=2";

    in ["${automount_opts},credentials=/etc/nixos/smb-secrets,iocharset=utf8,nostrictsync,noperm,uid=hinton,noexec"];
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usb", ID_INPUT_KEYBOARD=="1", ATTR{power/wakeup}="enabled"
  '';

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
}
