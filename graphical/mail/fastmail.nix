{
  accounts.email.accounts.fm = {
    address = "t@larkery.com";
    userName = "larkery@fastmail.fm";
    realName = "Tom Hinton";
    
    passwordCommand = "passm --print fastmail.fm";
    maildir.path = "fm";
    
    msmtp.enable = true;
    notmuch.enable = true;
    mbsync.enable = true;
    
    folders.sent = "Sent Items";
    folders.trash = "Deleted Items";

    imap.host = "mail.messagingengine.com";
    imap.port = 992;
    imap.tls.enable = true;
    imap.tls.useStartTls = false;
    
    mbsync.extraConfig.account = {
      "AuthMechs" = "LOGIN";
    };
    
    mbsync.create = "both";
    mbsync.expunge = "both";
    mbsync.patterns = [ "*" ];
    
    smtp.host = "mail.messagingengine.com";
    smtp.tls.enable = true;
  };
}
