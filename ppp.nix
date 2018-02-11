{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ppp;
in
{
  options = {
    services.ppp = {
      enable = mkEnableOption "ppp client service";

      config = mkOption {
        type = types.attrsOf (types.submodule (
          {
            options = {
              defaultroute = mkEnableOption "add default route";
              routes = mkOption { type = types.listOf types.str; };
              host = mkOption { type = types.str; };
              username = mkOption { type = types.str; };
              refuse-eap = mkEnableOption "refuse eap auth";
              usepeerdns = mkEnableOption "use peer DNS";
              mtu = mkOption { type = types.int; };

              extraOptions = mkOption {
                type = types.lines;
                default = "";
                description = "Extra ppp connection options";
              };
            };
          }
        ));

        default = {};
      };
    };
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "ppp_mppe" ];

    security.polkit.extraConfig =
    ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units") {
        if (action.lookup("unit").endsWith("-vpn.service")) { // hax
            var verb = action.lookup("verb");
            if (verb == "start" || verb == "stop" || verb == "restart") {
                return polkit.Result.YES;
            }
        }
      }
    });
    '';
  
    systemd.services = {} // (mapAttrs' (name: cfg: nameValuePair "${name}-vpn"
    {  description = "VPN for ${name}";
       serviceConfig = {
        ExecStart = "${pkgs.ppp}/sbin/pppd call ${name} nodetach nolog";
       };
    }) cfg.config);

    environment.etc =
      let
      ip-up = pkgs.writeScript "ppp-ip-up"
      ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.openresolv}/bin/resolvconf -x -a $IFNAME < /etc/ppp/resolv.conf
      ${pkgs.procps}/bin/pkill --signal HUP dnsmasq
      source /etc/ppp/configure-$VPN_CONFIGURATION ## how do I relate this?
      '';
      ip-down = pkgs.writeScript "ppp-ip-down"
      ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.openresolv}/bin/resolvconf -f -d $IFNAME
      ${pkgs.procps}/bin/pkill --signal HUP dnsmasq
      '';
      in
      { "ppp/ip-up" = { source = ip-up; };
        "ppp/ip-down" = { source = ip-down; };
      } //
      (listToAttrs
        (concatMap (name :
         let settings = cfg.config.${name}; # ${name}
                   fi = fn : lines :
                       {name = "ppp/${fn}";
                        value = { text = concatStringsSep "\n" lines; }; } ;
         in
         [
             (fi "configure-${name}"
             ([  "#!{pkgs.bash}/bin/bash"
                 "${pkgs.iproute}/bin/ip link set dev $IFNAME mtu ${toString settings.mtu}"
             ] ++
             (map (r : "${pkgs.iproute}/bin/ip route add '${r}' dev $IFNAME") settings.routes)
             )
             ## and route add r dev name over settings.routes
             )
             (fi "peers/${name}"
             [  "name \"${settings.username}\""
                "remotename \"${name}\""
                "set VPN_CONFIGURATION=${name}"
                "require-mppe-128"
                "nodeflate"
                "nobsdcomp"
                "pty \"${pkgs.pptp}/bin/pptp ${settings.host} --nolaunchpppd --timeout 0.02\""
                (optionalString settings.defaultroute "defaultroute")
                (optionalString settings.usepeerdns "usepeerdns")
                (optionalString settings.refuse-eap "refuse-eap")
                "${settings.extraOptions}"
             ]
             )
         ])
         (attrNames cfg.config)
         ));
     };
}
