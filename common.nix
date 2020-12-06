{config, pkgs, ...}:
{
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  i18n.defaultLocale = "en_GB.UTF-8";

  time.timeZone = "Europe/London";

  powerManagement.enable = true;

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  environment.profileRelativeEnvVars = {
    MANPATH = [ "/man" "/share/man" ] ;
  };

  users.extraUsers.hinton = {
    extraGroups = [ "wheel" "networkmanager" "input" "adbusers" "vboxusers" "video" ];
    isNormalUser = true;
    uid = 1000;
  };

  fonts.fonts = with pkgs;
  [dejavu_fonts symbola font-awesome-ttf noto-fonts
  liberation_ttf noto-fonts roboto roboto-mono roboto-slab emacs-all-the-icons-fonts
  ];
  fonts.fontconfig.defaultFonts.monospace = ["DejaVu Mono"];
  fonts.fontconfig.defaultFonts.sansSerif = ["DejaVu Sans"];

  services = {
    acpid.enable = true;
    tlp.enable = true;
    udisks2.enable = true;

    xserver = {
      enable = true;
      layout = "gb";
      xkbOptions = "ctrl:nocaps";
      
      displayManager.autoLogin = {enable = true; user = "hinton";};
      displayManager.defaultSession = "xfce+i3";

      desktopManager.xfce = {
        enable = true;
        enableXfwm = false;
        noDesktop = true;
      };
      
      windowManager.i3.enable = true;
      windowManager.i3.package = pkgs.i3-gaps;

      libinput = {
        enable = true;
        disableWhileTyping = true;
      };
    };
  };

  systemd.user.services.battery-alarm = {
     enable = true;
     wantedBy = ["default.target"];
     path = [pkgs.systemd pkgs.libnotify];
     script = ''
     SCP=/sys/class/power_supply
     [[ $(cat $SCP/AC/online) == 1 ]] && exit 0
     CAP=$(cat $SCP/BAT0/capacity)
     if [[ $CAP -lt 15 ]]; then
        ~/bin/notify -u critical "Low battery: $CAP%"
     elif [[ $CAP -lt 8 ]]; then
        ~/bin/notify -u critical "Critical battery: $CAP%" "Hibernating..."
        ${pkgs.systemd}/bin/systemctl hibernate
     fi
     '';
     startAt = "*:0/10";
  };

  programs.light.enable = true;
  programs.firejail.enable = true;
  programs.bandwhich.enable = true;
  programs.gnupg = {
    agent.enable = true;
    agent.enableSSHSupport = true;
    agent.pinentryFlavor = "gtk2";
  };

  networking.networkmanager = {
    enable = true;
    dhcp = "internal";
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
  
}
