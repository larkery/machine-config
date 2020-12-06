{config, pkgs, ...} :
{
  environment.systemPackages = with pkgs; [ cifs_utils ];
  services.autofs = {
    enable = true;
    debug = false;
    timeout = 60;
    autoMaster = let
      top = "/net file:${host}";
    # for some reason, as of recent builds, -DAUTOFS_HOST does not work.
    host = pkgs.writeText "auto-host" "* -fstype=autofs,-DAUTOFS_HOST=& program:${share}";
    share = pkgs.writeScript "auto-share" ''
      #!/bin/sh
      MOUNT_HOST=$(basename $PWD)
      MOUNT_SHARE="$1"
      CREDS_FILE=""
      if [ -f "$AUTOFS_HOME/.creds/$MOUNT_HOST/$MOUNT_SHARE" ]; then
         CREDS_FILE="$AUTOFS_HOME/.creds/$MOUNT_HOST/$MOUNT_SHARE"
      elif [ -f "$AUTOFS_HOME/.creds/$MOUNT_HOST" ]; then
         CREDS_FILE="$AUTOFS_HOME/.creds/$MOUNT_HOST"
      fi

      if [ -f "$CREDS_FILE" ]; then
         if ${pkgs.gnugrep}/bin/grep -q username= "$CREDS_FILE"; then
            CREDS=",credentials=$CREDS_FILE"
         else
            ENTRY=$(cat $CREDS_FILE)

            CREDS_FIFO=$(mktemp)
            chown -R $AUTOFS_USER $CREDS_FIFO
            chmod -R 700 $CREDS_FIFO

            (/run/wrappers/bin/su $AUTOFS_USER -c "DISPLAY=:0 /home/hinton/bin/passm --credentials '$CREDS_FIFO' $ENTRY" &)

            CREDS=",credentials=$CREDS_FIFO"
         fi
      fi
      IPADDR=$(${pkgs.fping}/bin/fping -m "$MOUNT_HOST" -A -a | head -n 1)
      UNC="://''${IPADDR:-$MOUNT_HOST}/$MOUNT_SHARE"
      echo '-fstype=cifs,echo_interval=15,vers=2.1,uid=$UID'"$CREDS"' '"$UNC"
    '';
  in top;
  };

  systemd.services.autofs.serviceConfig.ExecStart =
    with pkgs.lib;
    let
      cfg = config.services.autofs;
      autoMaster = pkgs.writeText "auto.master" cfg.autoMaster; # yuck
    in mkForce "${pkgs.autofs5}/bin/automount ${optionalString cfg.debug "-d"} -p /run/autofs.pid -t ${builtins.toString cfg.timeout} -n 5 ${autoMaster}";
}
