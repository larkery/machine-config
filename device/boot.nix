{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "mitigations=off" ]; # frankly my dear
  hardware.cpu.intel.updateMicrocode = true;
}
