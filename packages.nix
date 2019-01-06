{config, pkgs, ...}:
{
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
  (self : super : {
    emacs = super.emacs.override {
       withGTK2 = false;
       withGTK3 = false;
    };
    
    compton-custom = super.compton.overrideAttrs (_:
    {
      name = "compton-custom-hinton";
      src =
        super.fetchgit {
        url = "https://github.com/larkery/compton.git";
        rev = "3a28338cd8bd51188dbf000bfdf9404502a26ac8";
        sha256 = "07lyw2df9cjcjmjjv1j70m1j4k8r9hbqivxb2vp4fl8zrxb2rq38";
      };
    }
  );
     pass = super.pass.override {gnupg = self.gnupg;};
  })
  ];

  environment.systemPackages =
  let
    mkEmacs = (pkgs.emacsPackagesNgGen pkgs.emacs).emacsWithPackages;
    myEmacs = mkEmacs
      (e: [ e.pdf-tools pkgs.notmuch ] );
  in
  with pkgs; [
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

    xclip xorg.xclock xdotool xorg.xkill xorg.xbacklight xmacro xorg.xwininfo

    pinentry
    
    arandr autorandr
    dunst
    pavucontrol

    compton-custom
    libnotify

    firefox chromium
    pinentry
  ];

}
