{cfg, pkgs, ...}:
{
  services.syncthing = {
    enable = true;
    dataDir = "/home/hinton/.config/syncthing";
    user = "hinton";
    group = "users";
  };
}
