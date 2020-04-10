{config, pkgs, ...}:
{
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (self : super : {
      emacs = super.emacs.override {
        withGTK2 = false;
        withGTK3 = false;
        imagemagick = self.imagemagick;
      };

      dmenu = super.dmenu.overrideAttrs (a : {
        patches = [./patches/dmenu-number-output.patch];
      });

      pass = super.pass.override {gnupg = self.gnupg;};
      srandrd = self.callPackage ./srandrd.nix {};
    })
  ];
  
  environment.systemPackages =
  let
    mkEmacs = (pkgs.emacsPackagesNgGen pkgs.emacs).emacsWithPackages;
    myEmacs = mkEmacs
    (e: [ e.pdf-tools pkgs.notmuch e.org ] );


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
    
    replace-xdg = pkgs.writeScriptBin "replace-xdg" ''
      #! ${pkgs.bash}/bin/bash
      
      exec ${pkgs.bubblewrap}/bin/bwrap --dev-bind / / --bind ${fixed-xdg-utils} ${pkgs.xdg_utils} "$@"
    '';
  in
  with pkgs; [
    gnome3.defaultIconTheme
    hicolor_icon_theme oxygen numix-icon-theme
    gtk-engine-murrine zuki-themes vanilla-dmz
    gnome2.gnome_icon_theme
    
    myEmacs
    
    graphviz aspell aspellDicts.en w3m

    notmuch isync msmtp

    gitAndTools.gitFull

    vcsh mr pass gnupg
    file yad
    man-pages
    acpi
    zip unzip
    ag most htop jq which sqlite

    pamixer redshift xss-lock

    rxvt_unicode-with-plugins

    wpa_supplicant_gui

    xclip xorg.xclock xdotool xorg.xkill xorg.xbacklight xautomation xorg.xwininfo

    pinentry
    
    arandr autorandr srandrd
    dunst
    pavucontrol
    udiskie

    compton
    libnotify

    firefox
    chromium
    pinentry

    tdesktop

    replace-xdg
    
    (callPackage ./ms-teams.nix {})
  ];

}
