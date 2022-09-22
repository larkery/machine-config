{pkgs, ...}:
let
  # np = (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz");
  np = <nixpkgs>;
  # overlay-version = "c185db9302bd83c1d73029f3da6dc2e5fc79edde";
  # overlay-version = "5a501bb198eb96a327cdd3275608305d767e489d";
  # overlay-version = "e8bcf0ddb6fe849c8eead988eaf837b68e6019a7";
  overlay-version = "a764f50d7667f54e275ec1260de2f8d97b677525";
  nc-emacs = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/emacs-overlay/archive/${overlay-version}.tar.gz";
  });
  np-emacs = import np {
      overlays = [ nc-emacs ];
  };
  patchedEmacsGcc = np-emacs.emacsGcc.overrideAttrs (a : {
    patches = a.patches ++ [./emacs-malloc-trim.patch];
  });
in
{
   programs.emacs.enable = true;
   programs.emacs.package = patchedEmacsGcc;
   programs.emacs.extraPackages = epkgs : [
     epkgs.melpaPackages.pdf-tools
     epkgs.org
     pkgs.notmuch.emacs
     epkgs.nix-mode
     epkgs.modus-themes
     epkgs.use-package
     epkgs.emacsql
     epkgs.emacsql-sqlite
   ];
   services.emacs.enable = true;
   services.emacs.client.enable = true;
   services.emacs.socketActivation.enable = true;
   xresources.properties = {
     "Emacs*FontBackend" = "xft";
     "Emacs*font" = "Monospace-12";

     "Emacs*menubar" = "0";
     "Emacs*verticalScrollBars" = "0";
     "Emacs*toolBar" = "0";
   };
}
