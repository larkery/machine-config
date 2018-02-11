{config, pkgs, ...} :
{
  environment.systemPackages = with pkgs; [ cifs_utils ];
  services.autofs = {
    enable = true;

    timeout = 300;
    autoMaster = let
      top = "/net file:${host}";
    # for some reason, as of recent builds, -DAUTOFS_HOST does not work.
    host = pkgs.writeText "auto-host" "* -fstype=autofs,-DAUTOFS_HOST=& program:${share}";
    share = pkgs.writeScript "auto-share" ''
      #!/bin/sh
      MOUNT_HOST=$(basename $PWD)
      MOUNT_SHARE="$1"
      if [ -f "$AUTOFS_HOME/.creds/$MOUNT_HOST/$MOUNT_SHARE" ]; then
         CREDS=",credentials=$AUTOFS_HOME/.creds/$MOUNT_HOST/$MOUNT_SHARE"
      elif [ -f "$AUTOFS_HOME/.creds/$MOUNT_HOST" ]; then
         CREDS=",credentials=$AUTOFS_HOME/.creds/$MOUNT_HOST"
      else
         CREDS=""
      fi
      UNC="://$MOUNT_HOST/$MOUNT_SHARE"
      echo '-fstype=cifs,uid=$UID'"$CREDS"' '"$UNC"
    '';
  in top;
  };
}
