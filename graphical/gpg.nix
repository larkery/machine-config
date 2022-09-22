{
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 2*3600;
    defaultCacheTtlSsh = 2*3600;
    # auto-expand-secmem needed to stop things exploding
    extraConfig = ''
      auto-expand-secmem
    '';
  };
}
