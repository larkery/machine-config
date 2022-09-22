{config, pkgs, ...}:{
  console.useXkbConfig = true;
  i18n.defaultLocale = "en_GB.UTF-8";
  time.timeZone = "Europe/London";

  imports = [<home-manager/nixos>];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  
  home-manager.users.hinton.imports = [
    ./cli-packages.nix
    ./shell.nix
    ./emacs.nix
  ];
  
  users.users.hinton = {
    extraGroups =
      [ "wheel" "networkmanager" "video" "vboxusers"];
      isNormalUser = true;
      uid = 1000;
      shell = pkgs.zsh;
  };
  
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  environment.pathsToLink = [
    "/share/zsh"
  ];

  nixpkgs.config.allowUnfree = true;
  
  nixpkgs.overlays = [
    (self : super : {
      notmuch = super.notmuch.override {
        withEmacs = true;
      };

      pass = super.pass.override {
        gnupg = self.gnupg;
      };
    })
  ];
}
