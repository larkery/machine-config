{ stdenv, python3, makeWrapper } :
let
  python = python3.withPackages (ps : [ps.notmuch ps.ConfigArgParse]);
in
stdenv.mkDerivation rec {
  name = "refile";
  src = ./refile;
  unpackPhase = ''
    echo nop
  '';

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/refile
    chmod +x $out/bin/refile
    wrapProgram $out/bin/refile \
       --prefix PATH : ${python}/bin
  '';
}
