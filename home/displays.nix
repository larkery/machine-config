{
  home-manager.users.hinton = {config, pkgs, lib, ...} :
  let
    run-autorandr = pkgs.writeScript "run-autorandr" ''
      #!${pkgs.bash}/bin/bash
      
      debounce=$(( $(date +%s) - $(date +%s -r ~/.cache/last-randr) ))
      if ! pgrep -c arandr && [[ $debounce > 4 ]] ; then
         ${pkgs.autorandr}/bin/autorandr -c --default horizontal
      fi
    '';
  in
  {
    home.file.".config/autorandr" = {
      recursive = true;
      source = ./autorandr;
    };
    
    systemd.user.services.srandrd = {
      Unit = {
        Description = "srandrd autorandr trigger";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };

      Service = {
        ExecStart = "${pkgs.srandrd}/bin/srandrd -n ${run-autorandr}";
        Restart = "on-abort";
      };
    };

    systemd.user.services.lidwatch = {
      Unit = {
        Description = "lid switch autorandr trigger";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };

      Service = {
        ExecStart = let script = pkgs.writeScript "watch-lid-switch" ''
          #!${pkgs.bash}/bin/bash

          while true; do
             inotifywait /proc/acpi/button/lid/LID/state
             sleep 0.1
             ${run-autorandr}
          done
        ''; in "${script}";
        Restart = "on-abort";
      };
    };
  };
}
