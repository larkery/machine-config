{pkgs, lib, config, ...}:{
  imports = [./autorandr.nix];

  home.sessionPath = ["$HOME/.local/bin"];
  
  xsession.enable = true;
  xsession.scriptPath = ".hm-xsession";
  
  xsession.pointerCursor.package = pkgs.gnome3.adwaita-icon-theme;
  xsession.pointerCursor.name = "Adwaita";
  xsession.pointerCursor.size = 32;
  xsession.profileExtra = ''
    systemctl --user import-environment ${builtins.concatStringsSep " " (builtins.attrNames config.home.sessionVariables)}
    setxkbmap gb
  '';
  
  xsession.windowManager.i3 =
  let exec = x : "exec --no-startup-id ${x}";
      warp = "exec --no-startup-id ${pkgs.xdotool}/bin/xdotool getactivewindow mousemove --polar --window %1 0 0";
      workspaces = ["1" "2" "3" "4" "5" "6" "7" "8" "9"];
      output = (let output = pkgs.stdenv.mkDerivation {
        name = "i3-outputs";
        src = ./i3-outputs.sh;
        buildInputs = [pkgs.makeWrapper];
        unpackPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/i3-outputs
          chmod +x $out/bin/i3-outputs
        '';
        installPhase = ''
          echo nop
        '';
      
        fixupPhase = ''
          wrapProgram $out/bin/i3-outputs --prefix PATH : ${lib.makeBinPath [ pkgs.bash pkgs.jq pkgs.i3 ]}
        '';
      }; in (x : "exec --no-startup-id ${output}/bin/i3-outputs ${x}"));
      view = pkgs.writeScript "view-ws" ''
        #!${pkgs.bash}/bin/bash

        ST=$(${pkgs.i3}/bin/i3-msg -t get_workspaces)
        WSN=$1
        FOCUSED_OUTPUT=$(echo "$ST" | ${pkgs.jq}/bin/jq '.[] | select(.focused) | .output')
        OWNER=$(echo "$ST" | ${pkgs.jq}/bin/jq '.[] |select(.visible)| select(.num == '$WSN') | .output')
    	if [[ $FOCUSED_OUTPUT != $OWNER ]]; then
           ${pkgs.i3}/bin/i3-msg "''${OWNER:+move workspace to output $OWNER}; workspace number $WSN; move workspace to output $FOCUSED_OUTPUT; workspace number $WSN" 2>&1 >/dev/null
	else
	   ${pkgs.i3}/bin/i3-msg "workspace number $WSN"
	fi
      '';
      addModifier = mod : binds : lib.attrsets.mapAttrs' (n: v: {name = "${mod}+${n}"; value = v;}) binds;
  in {
    enable = true;
    config = {
      modifier = "Mod4";
      workspaceAutoBackAndForth = false;

      bars = [{
        fonts = { names = ["Sans"]; size = 11.0; };
        position = "bottom";
        trayOutput = "primary";
        statusCommand = "${pkgs.i3status}/bin/i3status -c ${./i3status.conf}";
      }];

      window.commands = [
        {
          criteria.window_role = "GtkFileChooserDialog";
          command = "floating disable, focus";
        }
        {
          command = "floating enable, move position mouse";
          criteria.class = "password-input|Yad";
        }
        {
          command = "floating enable";
          criteria.title = "Microsoft Teams Notification";
        }
        {
          command = "floating enable";
          criteria.class = "zoom";
          criteria.title = "zoom";
        }
        {
          command = "floating enable, move position mouse";
          criteria.class = "pavucontrol";
        }
        {
          command = "floating enable, move position mouse";
          criteria.class = ".blueman-manager-wrapped";
        }
      ];

      startup = [ {command = "flameshot";} ];
      
      keybindings = addModifier "Mod4"
        ({
	        q = "kill";
	        Return = exec "urxvt";
	        e = exec "emacsclient -c -n";
	        w = exec "firefox";
          "Shift+w" = exec "chromium --new-window";
	        period = "workspace next_on_output";
	        comma = "workspace prev_on_output";
          "Shift+slash" = exec "passm";

          u = "[urgent=\"newest\"] focus";
          "Shift+u" = "[urgent=\"newest\"] move workspace current, focus";
          
	        j = "focus left; ${warp}";
	        k = "focus down; ${warp}";
	        l = "focus right; ${warp}";
	        i = "focus up; ${warp}";

          "Shift+j" = "move left; ${warp}";
	        "Shift+k" = "move down; ${warp}";
	        "Shift+l" = "move right; ${warp}";
	        "Shift+i" = "move up; ${warp}";

          Left = "focus left; ${warp}";
	        Down = "focus down; ${warp}";
	        Right = "focus right; ${warp}";
	        Up = "focus up; ${warp}";

          "Shift+Left" = "move left; ${warp}";
	        "Shift+Down" = "move down; ${warp}";
	        "Shift+Right" = "move right; ${warp}";
	        "Shift+Up" = "move up; ${warp}";

	        h = "split h";
	        v = "split v";
	        f = "fullscreen toggle";
	        "Shift+t" = "layout toggle tabbed splitv splith";
	        t = "layout toggle splith splitv tabbed";

	        "Mod1+t" = "[workspace=__focused__] floating enable, floating disable; layout tabbed";
          b = "bar mode toggle";
	        d = "floating toggle, move position mouse";
	        a = "focus parent";
	        z = "move scratchpad";
	        y = output "scratchpad";
	        "Shift+c" = "reload";
	        "Shift+r" = "restart";
          p = exec "${pkgs.autorandr}/bin/autorandr -c --force";
          "Shift+p" = exec "xset dpms force standby";
          
          o = output "focus-next";
          "Shift+o" = output "shift-next";
          "Mod1+o" = output "swap";
          "equal" = output "pack";

	        space = exec "rofi -show combi";
        }
        // (addModifier "Mod1" (lib.attrsets.genAttrs workspaces (w : exec "${view} ${w}")))
        // (lib.attrsets.genAttrs workspaces (w : "workspace number ${w}"))
        // (addModifier "Shift" (lib.attrsets.genAttrs workspaces (w : "move container to workspace number ${w}"))))
      // {
        XF86MonBrightnessUp = exec "${pkgs.brightnessctl}/bin/brightnessctl s +5%";
        XF86MonBrightnessDown = exec "${pkgs.brightnessctl}/bin/brightnessctl s 5%-";

        XF86AudioMute = exec "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        XF86AudioMicMute = exec "${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        XF86AudioRaiseVolume = exec "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        XF86AudioLowerVolume = exec "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";

        XF86Launch1 = exec "systemctl hibernate";
      };
    };
  };

  xresources.extraConfig = ''
    #include ".Xresources_emacs"
  '';

  home.keyboard.options = ["ctrl:nocaps"];
  home.keyboard.variant = "uk";

  programs.rofi.enable = true;
  programs.rofi.theme = "gruvbox-dark-soft";
  
  programs.urxvt = {
    enable = true;
    fonts = ["xft:Mono:size=12"];
    scroll.bar.enable = false;
  };

  services.picom.enable = true;
  services.picom.experimentalBackends = true;
  services.picom.vSync = true;
  services.picom.extraOptions = ''
    glx-no-stencil = true;
    glx-no-rebind-pixmap = false;
    use-damage = false;
  '';

  services.network-manager-applet.enable = true;

  services.redshift.enable = true;
  services.redshift.tray = true;
  services.redshift.latitude = "51.4545";
  services.redshift.longitude = "-2.5879";
  services.pasystray.enable = true;

  services.dunst.enable = true;
  services.dunst.settings = {
    global = {
      follow = "mouse";
      transparency = 10;
      markup = "full";
      corner_radius = 5;
      geometry = "400x0-8+8";
      format = "<b>%s</b> %b";
      word_wrap = true;
      padding = 5;
      horizontal_padding = 5;
    };
    urgency_normal.timeout = 4;
  };
  
  services.syncthing.enable = true;
  services.syncthing.tray.enable = true;
  
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

  systemd.user.sockets.open = {
    Unit.Description = "Socket for xdg-open passthru";
    Socket.ListenStream = "@xdg-open.socket";
    Socket.Accept = "yes";
    Install.WantedBy = [ "graphical-session.target" ];
  };
  
  systemd.user.services."open@" = {
    Service.StandardInput = "socket";
    
    Service.ExecStart =
      let handle = pkgs.writeScript "open" ''
        #!${pkgs.zsh}/bin/zsh
        wd=""
        while read -r -d $'\0' line
        do
        if [[ -z $wd ]]; then
          wd=$line
        else
          cd $wd
          ${pkgs.bash}/bin/bash -l -c 'PATH=$PATH:$HOME/.local/bin exec /home/hinton/open "$@"' _ "$line"
          echo $?
        fi
        done
      '';
      in "${handle}";
  };

  services.screen-locker = {
    enable = true;
    xautolock.enable = false;
    lockCmd = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 pixel";
  };

  services.blueman-applet.enable = true;
  services.caffeine.enable = true;
}

