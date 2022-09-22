{pkgs, ...} : {
  programs.firefox.enable = true;
  programs.firefox.profiles.default = {
    settings = {
      "browser.search.region" = "GB";
      "browser.search.countryCode" = "GB";
      "browser.search.suggest.enabled" = false;
      "browser.search.widget.inNavBar" = false;
      "browser.shell.checkDefaultBrowser" = false;
      "browser.uidensity" = 1;
      "browser.urlbar.suggest.history" = false;
      "browser.urlbar.suggest.topsites" = false;
      "browser.urlbar.suggest.searches" = false;
      "browser.urlbar.suggest.openpage" = false;
      "browser.urlbar.update1" = false;
      "browser.urlbar.update1.interventions" = false;
      "browser.urlbar.update1.searchTips" = false;
      "browser.urlbar.update1.view.stripHttps" = false;
      "browser.startup.homepage" = "https://www.dailyzen.com";
      "browser.bookmarks.showMobileBookmarks" = true;
      "browser.search.isUS" = false;
      "general.useragent.locale" = "en-GB";
      "distribution.searchplugins.defaultLocale" = "en-GB";
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    };
    userChrome = builtins.readFile ./firefox-userchrome.css;
  };
  programs.chromium.enable = true;
  programs.chromium.package = pkgs.ungoogled-chromium;
  
  home.packages = with pkgs; [
    libreoffice
    arandr
    pavucontrol
    zoom-us
    signal-desktop
    qgis
    vlc
    inkscape
    gimp
    mupdf
    wmctrl
    sxiv
    flameshot
    
    (pkgs.stdenv.mkDerivation {
      name = "idle";
      src = ./bin/idle;
      nativeBuildInputs = [pkgs.makeWrapper];
      buildInputs = [pkgs.perl];
      unpackPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/idle
      '';
      installPhase = ":";
      postFixup = ''
      patchShebangs $out/bin
      wrapProgram $out/bin/idle --prefix PERL5LIB : ${with perlPackages; makePerlPath [CommonSense NetSSLeay MailIMAPClient IOSocketSSL LinuxInotify2]}
      '';
    })


    (pkgs.writeScriptBin "pmbsync" (with pkgs; ''
    #!${pkgs.bash}/bin/bash
    PATH=$PATH:${lib.makeSearchPath "bin" [gnugrep gnused isync coreutils]}
    exec ${pkgs.bash}/bin/bash ${./bin/pmbsync} "$@"
    ''))

    (pkgs.writeScriptBin "passm" (with pkgs; ''
    #!${pkgs.bash}/bin/bash
    PATH=$PATH:${lib.makeSearchPath "bin" [pass yad xautomation xclip rofi]}
    exec ${pkgs.perl}/bin/perl ${./bin/passm} "$@"
  ''))
  ];
}
