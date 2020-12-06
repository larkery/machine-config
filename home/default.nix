{
  imports = [
    <home-manager/nixos>
    
    ./office-mail.nix
    ./fastmail.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.users.hinton = {pkgs, ...} :
  let
    refile = pkgs.callPackage ./refile.nix {};
  in
  {
    programs.msmtp.enable = true;
    programs.mbsync.enable = true;
    programs.notmuch.enable = true;

    programs.notmuch.new.tags = ["inbox" "new"];
    programs.notmuch.hooks.preNew = ''
      readarray CHANGED < <(${refile}/bin/refile)
      if [[ -z $NO_SYNC ]] ; then
         CHANGED+=("cse:Inbox")
         CHANGED+=("fm:Inbox")
         pushd $MAIL_DIR >/dev/null
         RECENT=$(date +%s --date="3 hours ago")
         for md in *; do
           pushd "$md" >/dev/null
           for f in *; do
             if [[ $(date +%s -r "$f") -lt $RECENT ]]; then
               CHANGED+=("$md:$f")
             fi
           done
           popd >/dev/null
         done
         popd >/dev/null
         pmbsync "''${CHANGED[@]}"
      fi
    '';

    programs.notmuch.hooks.postNew = ''
      NEW=$(notmuch count -- is:new -is:sent)
      if [[ $NEW -gt 0 ]]; then
         notify-send -i mail-read "$NEW new messages"
      fi
      readarray CHANGED < <(${refile}/bin/refile)
      notmuch tag -new -- tag:new
      if [[ -z $NO_SYNC ]] && [[ ''${#CHANGED[@]} -gt 1 ]]; then
         pmbsync "''${CHANGED[@]}"
         notmuch new
      fi
    '';

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

    home.sessionVariables = {
      BROWSER = "xdg-open";
      MAIL_DIR = "$HOME/Maildir";
      ALTERNATE_EDITOR = "";
      EDITOR = "emacsclient";
      QUOTING_STYLE="literal";
      LESS = "-R -W";

      MSMTP_QUEUE = "~/.cache/msmtp/queue";
      MSMTP_LOG = "~/.cache/msmtp/log";
      
      EMAIL_QUEUE_QUIET = "t";

      XDG_DOWNLOAD_DIR = "$HOME/dl";
      XDG_DESKTOP_DIR = "$HOME";
      XDG_DOCUMENTS_DIR = "$HOME";
      XDG_MUSIC_DIR = "$HOME/music";
      XDG_PICTURES_DIR = "$HOME/photos";
      XDG_VIDEOS_DIR="$HOME/";
      XDG_TEMPLATES_DIR="$HOME/.templates";
      XDG_PUBLICSHARE_DIR="$HOME/public";
    };

    home.sessionPath = [ "$HOME/bin" ];
    
    home.file = {
      ".profile".text = ''
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        ulimit -S -c 0 >/dev/null 2>&1
        export SOURCED_PROFILE=1 # can't remember why or where
      '';

      ".xprofile".text = ''
        source ~/.profile
        echo $DBUS_SESSION_BUS_ADDRESS > .dbus_session_bus_address
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

      ".config/autorandr" = {
        recursive = true;
        source = ./autorandr;
      };
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
  };
}
