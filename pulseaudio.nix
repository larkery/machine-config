{cfg, pkgs, ...} :
{
  hardware.pulseaudio = {
    extraConfig = ''
    load-module module-raop-discover
    '';
    zeroconf.discovery.enable = true;
    enable = true;
    support32Bit = true;
    package = pkgs.pulseaudioFull;
  };
}
