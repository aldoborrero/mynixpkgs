{
  fetchFromGitHub,
  lib,
  python311Packages,
}:
python311Packages.buildPythonPackage rec {
  pname = "mkdocs-git-authors-plugin";
  version = "0.9.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "timvink";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-q0SlgvGofPhP3RtA5mCAtz6fgfRGAOhUnpTonTuztOw=";
  };

  buildInputs = with python311Packages; [
    setuptools
  ];

  nativeCheckInputs = with python311Packages; [
    pytestCheckHook
    pythonImportsCheckHook
    click
    mkdocs
    mkdocs-material
  ];

  propagatedBuildInputs = with python311Packages; [
    gitpython
    mkdocs
  ];

  # disable tests as includes more plugins
  doCheck = false;

  disabledTests = [
  ];

  pythonImportsCheck = [
    "mkdocs_git_authors_plugin"
  ];

  meta = with lib; {
    homepage = "hhttps://github.com/timvink/mkdocs-git-authors-plugin";
    description = "MkDocs plugin to display git authors of a page";
    changelog = "https://github.com/timvink/mkdocs-git-authors/releases/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [aldoborrero];
  };
}
