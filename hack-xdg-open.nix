{config, pkgs, ...}:
let
  real = pkgs.xdg_utils.overrideAttrs (x:{
    name = "real-xdg-utils";
    IRRELEVANT="1";
  });
  replacement = pkgs.writeScriptBin "xdg-open" ''
  #! ${pkgs.bash}/bin/bash
  export PATH=$PATH:${real}/bin
  TGT=$(type -P xdg-open)
  if [[ "$TGT" == "${pkgs.xdg_utils}/bin/xdg-open" ]]; then
    exec ${real}/bin/xdg-open "$@" # force loop break
  else
    exec xdg-open "$@"
  fi
'';
in
{
  fileSystems.xdg-utils = {
    mountPoint = "${pkgs.xdg_utils}/bin";
    fsType = "overlay";
    device = "overlay";
    options=[
      "lowerdir=${replacement}/bin:${real}/bin"
    ];
  };
}
