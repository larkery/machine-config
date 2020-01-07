{ config, pkgs, fetchpatch, ... }:

let
  v1="5";
  v2="4";
  v3="6";
  version = "${v1}.${v2}.${v3}";
  linux_ck = pkgs.linuxManualConfig {
    inherit version;
    
    src = pkgs.fetchurl {
      url = "mirror://kernel/linux/kernel/v${v1}.x/linux-${version}.tar.xz";
      sha256 = "1j4916izy2nrzq7g6m5m365r60hhhx9rqcanjvaxv5x3vsy639gx";
    };

    inherit (pkgs) stdenv;
    
    #stdenv = (overrideCC gccStdenv gcc8);
    
    modDirVersion = "${version}-ck1";
    allowImportFromDerivation = true;
    configfile = ./kconfig.config;
    kernelPatches = [
      { name="ck";
        patch=pkgs.fetchpatch {
          name="patch-${v1}.${v2}-ck1.xz";
          url = "http://ck.kolivas.org/patches/${v1}.0/${v1}.${v2}/${v1}.${v2}-ck1/patch-${v1}.${v2}-ck1.xz";
          sha256 = "0p2ccwlsmq0587x6cnbrk4h2bwpl9342bmhsbyi1a87cs2jfwigl";
        };
      }
      
      # pkgs.kernelPatches.bridge_stp_helper
      # pkgs.kernelPatches.modinst_arg_list_too_long    
    ];  
  };

  linuxPackages_ck = pkgs.recurseIntoAttrs ( pkgs.linuxPackagesFor linux_ck );
in
{
  boot.kernelPackages = linuxPackages_ck;  
}
