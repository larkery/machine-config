{config, pkgs, ...}:
{
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleUseXkbConfig = true;
    defaultLocale = "en_GB.UTF-8";
  };

  time.timeZone = "Europe/London";

  powerManagement.enable = true;

  environment.profileRelativeEnvVars = {
    MANPATH = [ "/man" "/share/man" ] ;
  };

  users.extraUsers.hinton = {
    extraGroups = [ "wheel" "networkmanager" "input" "adbusers" "vboxusers" ];
    isNormalUser = true;
    uid = 1000;
  };

  fonts.fonts = with pkgs;
  [dejavu_fonts inconsolata fira-mono hack-font symbola font-awesome-ttf noto-fonts];
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

      displayManager.auto.enable = true;
      displayManager.auto.user = "hinton";
      
      desktopManager.default = "none";
      desktopManager.xterm.enable = true;

      windowManager.default = "i3";
      windowManager.i3.enable = true;
      windowManager.i3.package = pkgs.i3-gaps;

      synaptics = {
        enable = true;
        vertEdgeScroll = false;
        twoFingerScroll = true;
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

}
