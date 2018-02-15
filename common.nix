{config, pkgs, ...}:
{
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleUseXkbConfig = true;
    defaultLocale = "en_GB.UTF-8";
  };

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs; [zsh];

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
  [dejavu_fonts hack-font symbola font-awesome-ttf noto-fonts];
  fonts.fontconfig.defaultFonts.monospace = ["Hack" "DejaVu Mono"];
  fonts.fontconfig.defaultFonts.sansSerif = ["DejaVu Sans"];


  nixpkgs.overlays = [
    (self: super:
      {
        haskellPackages = super.haskellPackages.override {
          overrides = self: super:
          {
            xmonad = pkgs.lib.overrideDerivation super.xmonad
              (old : {
              src =  pkgs.fetchgit {
                url = "https://github.com/larkery/xmonad-1.git";
                rev = "9570174e635c5f49bebe90d04ae9dde25678b8a5";
                sha256 = "1ii2axbcj86k2ckdjj9581g1d5drhp8qr6bdv0xj340k0f02a4ac";
              };
            });
          };
        };
      }
    )];

  services = {
    acpid.enable = true;
    tlp.enable = true;
    udisks2.enable = true;

    xserver = {
      enable = true;
      layout = "gb";
      xkbOptions = "ctrl:nocaps";
      windowManager.default = "xmonad";

      desktopManager.xterm.enable = false;

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };

      synaptics = {
        enable = true;
        vertEdgeScroll = false;
        twoFingerScroll = true;
      };

      displayManager.lightdm.enable = true;
      displayManager.lightdm.autoLogin.enable = true;
      displayManager.lightdm.autoLogin.user = "hinton";

    };
  };

}
