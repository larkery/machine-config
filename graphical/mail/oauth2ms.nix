{lib, python3Packages}:
python3Packages.buildPythonApplication {
  pname = "oauth2ms";
  version = "0.0.1";

  propagatedBuildInputs = [
    python3Packages.msal
    python3Packages.pyxdg
  ];
  src = ./oauth2ms;
}
