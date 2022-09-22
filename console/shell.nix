{pkgs, ...}:
{
  home.sessionVariables = {
    EDITOR = "emacsclient";
    ALTERNATE_EDITOR = "";
    QUOTING_STYLE = "literal";
    JAVA_TOOL_OPTIONS = "-XX:-OmitStackTraceInFastThrow";
  };
  
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    dotDir = ".config/zsh";

    autocd = true;

    initExtra = builtins.readFile ./zshrc.sh;

    shellAliases = {
      ls = "ls --color=always";
      ll = "ls -lh";
      cpy = "rsync --archive -hh --partial --info=stats1,progress2 --modify-window=1";
      sqlite = "rlwrap sqlite";
    };

    plugins = [
      {
        name = "zsh-histdb";
        src = pkgs.fetchFromGitHub {
          owner = "larkery";
          repo = "zsh-histdb";
          rev = "30797f0c50c31c8d8de32386970c5d480e5ab35d";
          sha256 = "1f7xz4ykbdhmjwzcc3yakxwjb0bkn2zlm8lmk6mbdy9kr4bha0ix";
        };
      }
    ];
  };

  programs.dircolors.enable = true;
  programs.dircolors.settings.EXEC="01;31"; #red
}
