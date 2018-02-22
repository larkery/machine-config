{cfg, pkgs, ...} :
{
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
}
