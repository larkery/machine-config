{stdenv, fetchFromGitHub, autoreconfHook, cyrus_sasl}:
stdenv.mkDerivation {
  name = "sasl2-oauth";
  src = fetchFromGitHub {
    "owner"= "robn";
    "repo"= "sasl2-oauth";
    "rev"= "4236b6fb904d836b85b55ba32128b843fd8c2362";
    "sha256"= "17c1131yy41smz86fkb6rywfqv3hpn0inqk179a4jcr1snsgr891";
    "fetchSubmodules" =  true;
  };
  nativeBuildInputs = [
    autoreconfHook cyrus_sasl
    # nixpkgs.legacyPackages."${system}".cyrus_sasl
  ];
}
