{config, pkgs, ...}:
{
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleUseXkbConfig = true;
    defaultLocale = "en_GB.UTF-8";
  };

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs; [
    zsh
    hicolor_icon_theme
    oxygen
    numix-icon-theme
  ];

  security.wrappers.slock = {
    source = "${pkgs.slock}/bin/slock";
    owner = "root";
    group = "wheel";
  };

  programs.zsh = {
    enable = true;
    shellInit = "";
    shellAliases = {};
    promptInit = "";
    loginShellInit = "";
    interactiveShellInit = "";
    enableCompletion = false;
  };

  nixpkgs.config.allowUnfree = true;

  powerManagement.enable = true;

  environment.profileRelativeEnvVars = {
    MANPATH = [ "/man" "/share/man" ] ;
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = "/var/run/current-system/sw/bin/zsh";
  users.extraUsers.hinton = {
    extraGroups = [ "wheel" "networkmanager" "input" "adbusers" ];
    isNormalUser = true;
    uid = 1000;
  };

  fonts.fonts = with pkgs;
  [dejavu_fonts inconsolata fira-mono hack-font symbola font-awesome-ttf noto-fonts];
  fonts.fontconfig.defaultFonts.monospace = ["Fira Mono" "DejaVu Mono"];
  fonts.fontconfig.defaultFonts.sansSerif = ["DejaVu Sans"];


  services = {
    acpid.enable = true;
    tlp.enable = true;
    udisks2.enable = true;

    xserver = {
      enable = true;
      layout = "gb";
      xkbOptions = "ctrl:nocaps";
      windowManager.default = "i3";
      
      desktopManager.default = "none";

      desktopManager.xterm.enable = true;

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };

      windowManager.i3.enable = true;
      windowManager.i3.package = pkgs.lib.overrideDerivation pkgs.i3-gaps
      (old : rec {
          version = "4.15.0.1";
          releaseDate = "2018-03-13";
          src = pkgs.fetchurl {
              url = "https://github.com/Airblader/i3/archive/${version}.tar.gz";
              sha256 = "16s6bink8yj3zix4vww64b745d5drf2vqjg8vz3pwzrark09hfal";
          };
          postUnpack = ''
              echo -n "${version} (${releaseDate})" > ./i3-${version}/I3_VERSION
          '';
      })
      ;

      synaptics = {
        enable = true;
        vertEdgeScroll = false;
        twoFingerScroll = true;
      };

      displayManager.auto.enable = true;
      displayManager.auto.user = "hinton";
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
