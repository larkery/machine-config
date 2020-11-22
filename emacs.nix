{ pkgs ? import <nixpkgs> {} }: 

let
  myEmacs = pkgs.emacs;

  emacsWithPackages = (pkgs.emacsPackagesGen myEmacs).emacsWithPackages; 
in
  emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [ 
    pdf-tools
  ]) ++ (with epkgs.orgPackages; [ 
    org
  ]) ++ [
    pkgs.notmuch.emacs
  ])
