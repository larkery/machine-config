{config, pkgs, ...}:
let tray-icon = cmd : after : {
  serviceConfig = {
    ExecStart = cmd;
    Restart = "on-failure";
  };
  wantedBy = ["graphical-session.target"];
  partOf = ["graphical-session.target"];
  enable = true;
};
in
{
  systemd.user.services = {
    nm-applet = tray-icon "${pkgs.networkmanagerapplet}/bin/nm-applet" [];
    redshift = tray-icon "${pkgs.redshift}/bin/redshift-gtk -l 51.455313:-2.591902" ["nm-applet"];

    pasystray = tray-icon "${pkgs.pasystray}/bin/pasystray" ["redshift"];

    udiskie = tray-icon "${pkgs.udiskie}/bin/udiskie -t" ["pasystray"];

  };
}
