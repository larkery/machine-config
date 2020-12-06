{config, pkgs, ...}:
{
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (self : super : {
      notmuch = super.notmuch.override {
        withEmacs = true;
      };

      emacs =  super.emacs.override {
        withGTK2 = false;
        withGTK3 = false;
#        imagemagick = self.imagemagick;
      };
      
      dmenu = super.dmenu.overrideAttrs (a : {
        patches = [./patches/dmenu-number-output.patch];
      });

      pass = super.pass.override {gnupg = self.gnupg;};
      srandrd = self.callPackage ./srandrd.nix {};

      i3-gaps = super.i3-gaps.overrideAttrs (o : rec {
        version = "4.19";
        src = self.fetchurl {
          url = "https://github.com/Airblader/i3/releases/download/${version}/i3-${version}.tar.xz";
          sha256 = "0j19kj05fpjfnj50vyykk6jsr07hq9l26y8na55bb7yfrra8yp4h";
        };
        nativeBuildInputs = (builtins.filter (x : x != self.autoreconfHook) o.nativeBuildInputs) ++ [ self.meson self.ninja ];
      });
    })
  ];
  
  environment.systemPackages =
    let
    fixed-xdg-utils = derivation {
      name = pkgs.xdg_utils.name;
      version = pkgs.xdg_utils.version;
      system = builtins.currentSystem;
      builder = let xo2 = pkgs.writeScript "xdg-open" ''
        #! ${pkgs.bash}/bin/bash
        exec ''${HOME}/bin/xdg-open "$@"
      '';
      in
      pkgs.writeScript "build" ''
        #! ${pkgs.bash}/bin/bash
        ${pkgs.coreutils}/bin/mkdir $out
        ${pkgs.coreutils}/bin/ln -s ${pkgs.xdg_utils}/* $out
        ${pkgs.coreutils}/bin/rm -rf $out/bin
        ${pkgs.coreutils}/bin/mkdir -p $out/bin
        ${pkgs.coreutils}/bin/ln -s ${pkgs.xdg_utils}/bin/* $out/bin
        ${pkgs.coreutils}/bin/ln -sf ${xo2} $out/bin/xdg-open
      '';
    };

    fix-xdg = ''${pkgs.bubblewrap}/bin/bwrap --dev-bind / / --bind ${fixed-xdg-utils} ${pkgs.xdg_utils}'';
    
    replace-xdg = pkgs.writeScriptBin "replace-xdg" ''
      #! ${pkgs.bash}/bin/bash
      
      exec ${fix-xdg} "$@"
    '';

    telegram-desktop = pkgs.writeScriptBin "telegram-desktop" ''
      #! ${pkgs.bash}/bin/bash
      exec ${fix-xdg} ${pkgs.tdesktop}/bin/telegram-desktop "$@"
    '';

    chromium = pkgs.writeScriptBin "chromium" ''
      #! ${pkgs.bash}/bin/bash
      exec ${fix-xdg} ${pkgs.chromium}/bin/chromium "$@"
    '';

    teams = pkgs.writeScriptBin "teams" ''
      #! ${pkgs.bash}/bin/bash
      exec ${fix-xdg} ${pkgs.teams}/bin/teams "$@"
    '';
  in
  with pkgs;
  let
    theme-junk = [
      gnome3.defaultIconTheme
      hicolor_icon_theme oxygen numix-icon-theme
      gtk-engine-murrine zuki-themes vanilla-dmz
      gnome2.gnome_icon_theme
    ];
    emacs = [
      (import ./emacs.nix { inherit pkgs; })
      graphviz aspell aspellDicts.en w3m ditaa gnuplot
    ];
    email = [
      notmuch isync msmtp
    ];
    utils = [
      zip unzip bzip2 gzip p7zip atool lzip unrar
      gitAndTools.gitFull vcsh mr
      pass gnupg
      file which
      man-pages
      ag most htop
      sqlite
      jq
      replace-xdg
      sstp
      pv
      ripgrep
      rlwrap
      lsof
      fd
      direnv
      feh
      ncdu
      nix-prefetch-git
      wget
      bubblewrap
    ];
    gui-junk = [
      yad
      rxvt_unicode-with-plugins
      xclip xorg.xclock xdotool xorg.xkill xorg.xbacklight xautomation xorg.xwininfo
      wmctrl
      pamixer
      xss-lock
      dunst libnotify
      arandr autorandr
      rofi
      pavucontrol
      xorg.transset
      maim
    ];
    apps = [
      firefox chromium telegram-desktop teams inkscape gimp libreoffice
      mupdf
      spotify
      zoom-us
      vlc
    ];
    gis = [
      qgis gdal
    ];
  in
   theme-junk ++ emacs ++ email ++ utils ++ gui-junk ++ apps ++ gis
   ;
}
