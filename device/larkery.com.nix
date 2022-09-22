{config, pkgs, ...}:{
  imports = [
    ./larkery.com-hardware.nix
    ../console
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device="/dev/sda";
  boot.loader.timeout = 10;
  boot.loader.grub.forceInstall = true;

  boot.kernelParams = ["console=ttyS0,19200n8"];
  boot.loader.grub.extraConfig = ''
    serial --speed=19200 --unit=0 --word=8 --partiy=no --stop=1;
    terminal_input serial;
    terminal_output serial;
  '';

  environment.systemPackages = with pkgs; [
      rxvt_unicode.terminfo
  ];

  services.openssh.enable = true;
  services.openssh.ports = [ 2223 ];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@larkery.com";

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;

    virtualHosts."larkery.com" = {
      enableACME = true;
      forceSSL = true;
      root = "/data/web/larkery.com";
    };
  };

  networking.firewall.allowedTCPPorts = [2223 80 443];
  
  system.stateVersion = "18.09";
}
