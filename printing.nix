{config, pkgs, ...}:
{
  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.gutenprint
    pkgs.samsung-unified-linux-driver_1_00_37
    ./bizhub
  ];

  hardware.printers.ensurePrinters = [
     {
      description = "The big printer in work";
      deviceUri = "ipp://10.0.0.3/ipp";
      location = "Office";
      name = "bizhub";
      model = "BIZHUB.ppd";
      ppdOptions = {
        PageSize = "A4";
        Model = "C558";
      };
    }
    {
      name = "PrintyMcPrintface";
      description = "Printy McPrintface";
      deviceUri = "ipp://PRINTYMCPRINTFA.home/ipp/";
      ppdOptions = {
        PageSize = "A4";
      };
      model = "Samsung_SCX-4500W_Series.ppd.gz";
    }
  ];
}
