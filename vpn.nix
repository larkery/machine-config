{config, pkgs, ...}:
{
  environment.systemPackages = [
    (pkgs.buildEnv {
      ignoreCollisions = true;
      name = "ppp";
      paths = [
        
        (pkgs.stdenv.mkDerivation {
          name = "patched-poff";
          unpackPhase = ''
            echo hi
          '';
          installPhase = ''
            mkdir -p $out/bin
            cp ${pkgs.ppp}/bin/poff $out/bin/poff
            sed -ie 's!KILL="/bin/kill"!KILL="${pkgs.coreutils}/bin/kill"!g' $out/bin/poff
          '';
        })

        pkgs.ppp
      ];
    }

    )
  ];
  services.pppd = {
    enable = true;
    peers.cse.enable = true;
    peers.cse.autostart = false;
    peers.cse.config = ''
      remotename cse
      linkname cse
      ipparam cse
      pty "${pkgs.sstp}/bin/sstpc --ipparam cse --nolaunchpppd vpn.cse.org.uk"
      name cse\\tomh
      plugin ${pkgs.sstp}/lib/pppd/sstp-pppd-plugin.so
      sstp-sock /var/run/sstpc/sstpc-cse
      usepeerdns
      require-mppe
      refuse-eap
      refuse-pap
      refuse-chap
      refuse-mschap
      nobsdcomp
      nodeflate
      noauth
    '';
  };

  environment.etc = {
    "ppp/ip-up" = {
      text = ''
        #! ${pkgs.bash}/bin/bash
        ${pkgs.iproute}/bin/ip route add 10.0.0.0/8 dev $1
        ${pkgs.openresolv}/bin/resolvconf -a $1 < /etc/ppp/resolv.conf
      '';
      mode = "0755";
    };
    "ppp/ip-down" = {
      text = ''
        #! ${pkgs.bash}/bin/bash
        ${pkgs.openresolv}/bin/resolvconf -d $1
      '';
      mode = "0755";
    };
  };
}
