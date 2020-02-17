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

  #   gnupg = super.gnupg.overrideAttrs
  #   (o : {
  #     patches = o.patches ++ [
  #       ./patches/gpg-notify.patch
  #     ];
  #   });
  })
  ];
  
  environment.systemPackages =
  let
    mkEmacs = (pkgs.emacsPackagesNgGen pkgs.emacs).emacsWithPackages;
    myEmacs = mkEmacs
    (e: [ e.pdf-tools pkgs.notmuch e.org ] );
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

    firefox chromium
    pinentry
  ];

}
