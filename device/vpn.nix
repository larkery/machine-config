{config, pkgs, ...}:
let ppp = pkgs.buildEnv {
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
};
in
{
  environment.systemPackages = [ ppp ];

  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "${ppp}/bin/pon";
          options = [ "SETENV" "NOPASSWD" ];
        }
        {
          command = "${ppp}/bin/poff";
          options = [ "SETENV" "NOPASSWD" ];
        }
      ];
    }
  ];
  
  services.pppd = {
    enable = true;
    peers.cse.enable = true;
    peers.cse.autostart = false;
    peers.cse.config = ''
      remotename cse
      linkname cse
      ipparam cse
      pty "${pkgs.sstp}/bin/sstpc --cert-warn --ipparam cse --nolaunchpppd vpn.cse.org.uk"
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
    "ppp/resolv.conf" = {
      text = ''
        nameserver 10.0.0.208
      '';
      mode = "0755";
    };
    "NetworkManager/dnsmasq.d/ppp.conf".text = let dns = "10.0.0.208"; in ''
      server=/cse-bs3-data.cse.org.uk/${dns}
      server=/cse-bs3-file.cse.org.uk/${dns}
      server=/r.cse.org.uk/${dns}
    '';
    "ppp/ip-up" = {
      text = ''
        #! ${pkgs.bash}/bin/bash
        ${pkgs.iproute}/bin/ip route add 10.0.0.0/8 dev $1
      '';
      mode = "0755";
    };
    # "ppp/ip-down" = {
    #   text = ''
    #     #! ${pkgs.bash}/bin/bash
    #     rm -f /etc/NetworkManager/dnsmasq.d/ppp.conf
    #   '';
    #   mode = "0755";
    # };
  };
}
