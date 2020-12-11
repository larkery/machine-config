{
  imports = [
    <home-manager/nixos>
    
    ./displays.nix
    ./email.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.users.hinton = {config, pkgs, lib, ...} :
  {
    services.picom.enable = true;
    services.picom.experimentalBackends = true;
    services.picom.vSync = true;
    services.picom.extraOptions = ''
      glx-no-stencil = true
      glx-no-rebind-pixmap = true
      use-damage = true
    '';
    
    services.pasystray.enable = true;
    services.udiskie.enable = true;
    services.network-manager-applet.enable = true;

    services.redshift.enable = true;
    services.redshift.tray = true;
    services.redshift.latitude = "51.4545";
    services.redshift.longitude = "-2.5879";

    services.dunst.enable = true;
    services.dunst.iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    services.dunst.settings = {
      global = {
        follow = "mouse";
        geometry = "0x0-0+0";
        icon_position = "left";
        vertical_alignment = "top";
        transparency = 10;
        horizontal_padding = 20;
        max_icon_size=24;
        min_icon_size=24;
        padding = 6;
        format = ''
          %s %p %I 
          %b'';
        markup = "full";
      };
    };

    home.sessionVariables = {
      BROWSER = "xdg-open";

      ALTERNATE_EDITOR = "";
      EDITOR = "emacsclient";
      QUOTING_STYLE="literal";
      LESS = "-R -W";

      # home.sessionPath appends rather than prepends.
      
      PATH=''$HOME/bin''${PATH:+:}$PATH'';
      LD_LIBRARY_PATH=''$LD_LIBRARY_PATH''${LD_LIBRARY_PATH:+:}${pkgs.xorg.libXcursor}/lib'';
    };

    home.file = {
      ".profile".text = ''
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        ulimit -S -c 0 >/dev/null 2>&1
        export SOURCED_PROFILE=1 # can't remember why or where
      '';

      ".xprofile".text = ''
        source ~/.profile
        echo $DBUS_SESSION_BUS_ADDRESS > .dbus_session_bus_address
        setxkbmap

        xfconf-query --channel xsettings --property /Gtk/CursorThemeName ${config.xsession.pointerCursor.name}
        xfconf-query --channel xsettings --property /Gtk/CursorThemeSize ${toString config.xsession.pointerCursor.size}
      '';

      "bin" = {
        recursive = true;
        source = ./bin;
      };

      ".mrconfig".text = let gh = "git clone git@github.com:larkery"; in
      pkgs.lib.generators.toINI {} {
        "$HOME/.config/emacs"   = { "checkout" = "${gh}/emacs.git emacs"; };
        "$HOME/.config/i3"      = { "checkout" = "${gh}/i3.git i3"; };
        "$HOME/.config/zsh"     = { "checkout" = "${gh}/zsh.git zsh"; };
        "$HOME/.password-store" = { "checkout" = "git clone ssh://larkery.com:/home/hinton/repos/pass .password-store"; };
      };

      ".zshenv".text = ''
        export ZDOTDIR=$HOME/.config/zsh
      '';

      ".config/html-tidy/tidy.conf".text = ''
        indent-spaces: 2
        wrap: 100
        markup: yes
        output-xml: yes
        input-xml: no
        show-warnings: no
        word-2000: yes
        numeric-entities: yes
        break-before-br: no
        uppercase-tags: no
        ascii-chars: yes
        clean: yes
        output-encoding: utf8
        uppercase-attributes: no
        new-inline-tags: cfif, cfelse, math, mroot,
          mrow, mi, mn, mo, msqrt, mfrac, msubsup, munderover,
          munder, mover, mmultiscripts, msup, msub, mtext,
          mprescripts, mtable, mtr, mtd, mth
        new-blocklevel-tags: cfoutput, cfquery
        new-empty-tags: cfelse
      '';
    };

    xresources.properties = {
      "URxvt.perl-ext-common" = "default";
      "URxvt.perl-ext" = "reload-resources";
      "URxvt.perl-lib" = "${./urxvt-ext}";
      "URxvt.font" = "xft:Monospace:size=12";
      "URxvt.boldFont" = "xft:Monospace:size=12:weight=bold";

      "URxvt*urgentOnBell" = "true";
      "URxvt*saveLines" = "5000";

      "URxvt*scrollWithBuffer" = "True";
      "URxvt*scrollTtyOutput" = "False";
      "URxvt*scrollTtyKeypress" = "True";
      "URxvt*secondaryScreen" = "True";
      "URxvt*secondaryScroll" = "False";
      "URxvt*secondaryWheel" = "True";

      "URxvt*dynamicColors" = "true";

      "URxvt*scrollBar" = "false";

      "Emacs*FontBackend" = "xft";
      "Emacs*font" = "Monospace-12";

      "Emacs*menubar" = "0";
      "Emacs*verticalScrollBars" = "0";
      "Emacs*toolBar" = "0";

      "rofi.kb-row-tab" = "Tab,Super+space";
    };

    xresources.extraConfig = ''
      #include "/home/hinton/.Xresources_emacs"
      
    '';

    xdg.userDirs.enable = true;
    xdg.userDirs = {
      desktop = "$HOME";
      documents = "$HOME/misc";
      download = "$HOME/dl";
      music = "$HOME/music";
      templates = "$HOME/.config/templates";
      videos = "$HOME";
      publicShare = "$HOME/.share/public";
      pictures = "$HOME";
    };

    
    xsession.pointerCursor = {
      package = pkgs.gnome3.adwaita-icon-theme;
      name = "Adwaita";
      size = 32;
    };
  };
}
