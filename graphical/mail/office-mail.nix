{
  accounts.email.accounts.cse = {
    address = "tom.hinton@cse.org.uk";
    userName = "tomh@cse.org.uk";
    realName = "Tom Hinton";
    primary = true;
    
    passwordCommand = "passm --print cse.org.uk";
    maildir.path = "cse";
    
    msmtp.enable = true;
    notmuch.enable = true;
    mbsync.enable = true;
    
    folders.sent = "Sent Items";
    folders.trash = "Deleted Items";

    imap.host = "outlook.office365.com";
    imap.tls.enable = true;
    imap.tls.useStartTls = true;
    
    mbsync.extraConfig.account = {
      "PipelineDepth" = 1;
      "AuthMechs" = "LOGIN";
    };
    mbsync.create = "both";
    mbsync.expunge = "both";
    mbsync.patterns = [
      "INBOX" "Drafts" "Sent Items"
      "Deleted Items"
      "Archives"
      "Archives/*"
    ];
    
    smtp.host = "smtp.office365.com";
    smtp.tls.enable = true;
    smtp.tls.useStartTls = true;
  };

}
