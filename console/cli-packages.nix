{pkgs, ...}: {
  home.packages = with pkgs; [
    htop
    file
    zile
    pandoc
    atool zip unzip
    sqlite
    rlwrap
    ripgrep
    tmux
    gdal
    git
    most
    ncdu
    nmap
    pass
    jq
    
    (let src = builtins.fetchGit {
      url = "https://github.com/Shopify/comma.git";
      rev = "4a62ec17e20ce0e738a8e5126b4298a73903b468";
    }; in pkgs.callPackage src {})
  ];

  programs.git = {
    enable = true;
    ignores = [ "*~" ".#*" ];
    userEmail = "tom.hinton@cse.org.uk";
    userName = "Tom Hinton";
    extraConfig = {
      pull = {rebase = false;};
    };
  };

}
