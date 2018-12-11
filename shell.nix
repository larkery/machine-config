{config, pkgs, ...}:
{
  users.defaultUserShell = "/var/run/current-system/sw/bin/zsh";
  programs.zsh = {
    enable = true;
    shellInit = "";
    shellAliases = {};
    promptInit = "";
    loginShellInit = "";
    interactiveShellInit = "";
    enableCompletion = false;
  };
}
