{config, pkgs, ...}:{
  fonts = {
    fonts = with pkgs; [
      dejavu_fonts
      emacs-all-the-icons-fonts
      font-awesome-ttf
      corefonts
      vistafonts
    ];
    fontconfig.defaultFonts = {
      monospace = ["DejaVu Mono"];
      sansSerif = ["DejaVu Sans"];
      serif = ["DejaVu Serif"];
    };
  };

  services.xserver = {
    enable = true;
    layout = "gb";
    xkbOptions = "ctrl:nocaps";

    libinput = {
      enable = true;
      touchpad.disableWhileTyping = true;
    };

    deviceSection = ''
      Option "TearFree" "true"
    '';

    desktopManager.session = [
      {
        name = "i3";
        start = ''
          ${pkgs.runtimeShell} $HOME/.hm-xsession &
          waitPID=$!
        '';
      }
    ];
  };

  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "dnsmasq";
  environment.etc."NetworkManager/dnsmasq.d/block.conf".text = ''
    address=/reddit.com/
    address=/ycombinator.com/
    address=/boingboing.net/
    address=/neatorama.com/
  '';
  
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.jack.enable = true;
  services.pipewire.package = (import <unstable> {}).pipewire;

  services.avahi.enable = true;
  
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };

  home-manager.users.hinton.imports = [
    ./xsession.nix
    # ./gpg.nix
    ./gui-packages.nix
    ./mail
  ];

  fileSystems.xdg-override = {
    mountPoint = "${pkgs.xdg_utils}/bin/xdg-open";
    device = "${pkgs.xdg_override}/bin/xdg-open";
    options = [ "bind" "ro" ];
  };

  nixpkgs.overlays = [
    (self : super :
    let sasl-path = "${super.cyrus_sasl.out.outPath}/lib/sasl2:${self.cyrus_sasl_xoauth2}/lib/sasl2"; in
    {
      cyrus_sasl_xoauth2 = super.callPackage ./cyrus-sasl-xoauth2.nix {};

      msmtp = super.buildEnv {
        name = "msmtp";
        paths = [super.msmtp];
        pathsToLink = ["/bin"];
        nativeBuildInputs = [super.makeWrapper];
        postBuild = ''
          wrapProgram "$out/bin/msmtp" --prefix SASL_PATH : "${sasl-path}"
          wrapProgram "$out/bin/msmtpd" --prefix SASL_PATH : "${sasl-path}"
          wrapProgram "$out/bin/msmtpq" --prefix SASL_PATH : "${sasl-path}"
          wrapProgram "$out/bin/msmtp-queue" --prefix SASL_PATH : "${sasl-path}"
        '';
      };
      
      isync = super.buildEnv {
        name = "isync";
        paths = [super.isync];
        pathsToLink = ["/bin"];
        nativeBuildInputs = [super.makeWrapper];
        postBuild = ''
          wrapProgram "$out/bin/mbsync" --prefix SASL_PATH : "${sasl-path}"
        '';
      };
    })
    
    (self : super : {
      xdg_override = pkgs.writeScriptBin "xdg-open" ''
        #!${pkgs.zsh}/bin/zsh
        if [[ $1 == --block ]]; then
        shift
        zmodload zsh/system
        { echo $PWD$'\0'$1$'\0'; } |
        ${pkgs.socat}/bin/socat -t 360000 - ABSTRACT-CONNECT:xdg-open.socket |
        sysread answer
        exit $answer
        else
        { echo $PWD$'\0'$1$'\0'; } |
        ${pkgs.socat}/bin/socat - ABSTRACT-CONNECT:xdg-open.socket
        fi
      '';
    })
  ];
  
}
