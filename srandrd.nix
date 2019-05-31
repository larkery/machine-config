{stdenv, fetchFromGitHub, xorg}:
stdenv.mkDerivation rec {
  version = "0.6.1";
  name = "srandrd-${version}";

  buildInputs = [xorg.libX11 xorg.libXrandr xorg.libXinerama];

  src = fetchFromGitHub {
    owner = "jceb";
    repo = "srandrd";
    sha256 = "174vbya270gmpkfvgv1p0y5h023mm985a6sjln8s7vgvm13ix9c9";
    rev = "1ab4880b0f2154e0b1b8d4acf7188a8c63d0fa5b";
  };

  installPhase = ''
    PREFIX=$out make install
  '';
}
