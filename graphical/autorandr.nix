{pkgs, ...} :
let
  ## this runs autorandr but debounces it a bit
  autorandr = pkgs.writeScript "run-autorandr" ''
    #!${pkgs.bash}/bin/bash
    LOCKF=$HOME/.local/autorandr-lock
    ${pkgs.coreutils}/bin/touch $LOCKF
    exec {FD}<>$LOCKF

    ${pkgs.utillinux}/bin/flock -x $FD

    if ! ${pkgs.procps}/bin/pgrep -c arandr ; then
       ${pkgs.autorandr}/bin/autorandr -c --default horizontal --skip-options gamma
       sleep 2
    fi
  '';
  watch-lid = pkgs.writeScript "watch-lid" ''
    #!${pkgs.bash}/bin/bash
    while true; do
     ${pkgs.inotify-tools}/bin/inotifywait /proc/acpi/button/lid/LID/state
     $1
    done
  '';
  srandrd = pkgs.callPackage ./srandrd.nix {};
  gss = s : s // {
    Unit = s.Unit // {
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Install = { WantedBy = [ "graphical-session.target" ];};
  };
in {
  systemd.user.services.srandrd = gss {
    Unit.Description = "hotplug autorandr";
    Service.ExecStart = "${srandrd}/bin/srandrd -n ${autorandr}";
    Service.Restart = "on-abort";
  };
  systemd.user.services.lid-randr = gss {
    Unit.Description = "lid switch autorandr";
    Service.ExecStart = "${watch-lid} ${autorandr}";
    Service.Restart = "on-abort";
  };

  programs.autorandr.enable = true;
  programs.autorandr.hooks.postswitch = {
    setroot = "${pkgs.hsetroot}/bin/hsetroot -extend ${pkgs.nixos-artwork.wallpapers.stripes-logo}/share/backgrounds/nixos/nix-wallpaper-stripes-logo.png";
  };
}
