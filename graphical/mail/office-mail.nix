{pkgs, ...}:
{
  home.file.".config/oauth2ms/config.json".text = ''
    {
    "tenant_id": "d42a95f1-8afd-40de-86a8-554bc9b34e78",
    "client_id": "7878d2a9-f684-453b-8534-03ade17a4643",
    "client_secret": "zpn8Q~S50ugpo1Apy~B7abvTRg1P96rMvve.ZbW.",
    "redirect_host": "localhost",
    "redirect_port": "5000",
    "redirect_path": "/getToken/",
    "scopes": ["https://outlook.office.com/IMAP.AccessAsUser.All", "https://outlook.office.com/SMTP.Send"]
    }
  '';
  
  accounts.email.accounts.cse = {
    address = "tom.hinton@cse.org.uk";
    userName = "tomh@cse.org.uk";
    realName = "Tom Hinton";
    primary = true;
    
    passwordCommand = let oauth2ms = pkgs.callPackage ./oauth2ms.nix {};
    in "${oauth2ms}/bin/oauth2ms.py";
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
      "AuthMechs" = "XOAUTH2";
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
    msmtp.extraConfig = {
      auth = "xoauth2";
    };
  };

}
