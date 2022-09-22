{config, pkgs, lib, ...}:
let
  refile = pkgs.callPackage ./refile.nix {};
in
{
  imports = [
    ./office-mail.nix
    ./fastmail.nix
  ];
  
  home.sessionVariables = {
    MAIL_DIR = "$HOME/Maildir";
    MSMTP_QUEUE = "$HOME/.cache/msmtp/queue";
    MSMTP_LOG = "$HOME/.cache/msmtp/log";
    EMAIL_QUEUE_QUIET = "t";
  };
  
  programs.msmtp.enable = true;
  programs.mbsync.enable = true;
  programs.notmuch.enable = true;
  
  programs.notmuch.new.tags = ["inbox" "new"];
  programs.notmuch.hooks.preNew = ''
    readarray CHANGED < <(${refile}/bin/refile)
    if [[ -z $NO_SYNC ]] ; then
    CHANGED+=("cse:INBOX")
    CHANGED+=("fm:INBOX")
    pushd $MAIL_DIR >/dev/null
    RECENT=$(date +%s --date="3 hours ago")
    for md in *; do
    pushd "$md" >/dev/null
    for f in *; do
    if [[ $(date +%s -r "$f") -lt $RECENT ]] || [[ "$f/.mbsyncstate" -ot "$f" ]]; then
    CHANGED+=("$md:$f")
    fi
    done
    popd >/dev/null
    done
    popd >/dev/null
    pmbsync "''${CHANGED[@]}"
    fi
  '';

  programs.notmuch.hooks.postNew = ''
    export PATH=$PATH:${pkgs.jq}/bin
    readarray CHANGED < <(${refile}/bin/refile)

    NEW=$(notmuch count -- is:new and is:inbox and is:unread)
    if [[ $NEW -gt 0 ]]; then
    ${pkgs.libnotify}/bin/notify-send -i mail-client "$NEW message(s)" "$(notmuch search --format=json tag:new and tag:inbox and is:unread | jq -r '.[] | "<b>\(.authors|split("[|,] *"; "g")|.[0])</b>: \(.subject)"')"
    fi
    notmuch tag -new -- tag:new
    if [[ -z $NO_SYNC ]] && [[ ''${#CHANGED[@]} -gt 1 ]]; then
    pmbsync "''${CHANGED[@]}"
    notmuch new
    fi
  '';
}
