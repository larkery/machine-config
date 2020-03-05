{config, pkgs, ...}:
{
  systemd.services.arandrWake =
    let targets = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
    in {
      enable = true;
      wantedBy = targets;
      script = ''
        export DISPLAY=:0
        ${pkgs.autorandr}/bin/autorandr -c
      '';
      after = targets;
      serviceConfig = { User = "hinton"; };
    };
}
