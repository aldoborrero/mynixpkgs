{
  buildPythonPackage,
  fetchFromGitHub,
  lib,
  pytestCheckHook,
  pythonOlder,
  prometheus-client,
  pyemvue,
  setuptools,
}:
buildPythonPackage {
  pname = "emvue-exporter";
  version = "0.0.1";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "shouptech";
    repo = "emvue_exporter";
    rev = "7ee3c4f91b73768877b26c26cb5b07278fd35696";
    hash = "sha256-Mx3JvLWzPGPOt+MXCRpPVNy9t32GnBa2ZaHLmfMYWhg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    setuptools
  ];

  propagatedBuildInputs = [
    prometheus-client
    pyemvue
  ];

  pythonImportsCheck = [
    "emvue-exporter"
  ];

  meta = with lib; {
    homepage = "https://github.com/shouptech/emvue-exporter";
    description = "";
    license = licenses.gpl3;
    maintainers = with maintainers; [aldoborrero];
  };
}
