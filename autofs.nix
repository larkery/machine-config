{config, pkgs, ...} :
{
  environment.systemPackages = with pkgs; [ cifs_utils ];
  services.autofs = {
    enable = true;
    debug = false;
    timeout = 300;
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

            (/run/wrappers/bin/su $AUTOFS_USER -c "/home/hinton/bin/passm --credentials '$CREDS_FIFO' $ENTRY" &)

            CREDS=",credentials=$CREDS_FIFO"
         fi
      fi

      UNC="://$MOUNT_HOST/$MOUNT_SHARE"
      echo '-fstype=cifs,echo_interval=20,vers=2.1,uid=$UID'"$CREDS"' '"$UNC"
    '';
  in top;
  };
}
