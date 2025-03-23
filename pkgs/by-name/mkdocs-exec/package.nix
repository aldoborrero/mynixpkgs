{python312Packages}:
python312Packages.callPackage ({
    buildPythonPackage,
    fetchFromGitHub,
    lib,
    mkdocs,
    pdm-backend,
    pymdown-extensions,
    pytestCheckHook,
    pythonOlder,
  }:
    buildPythonPackage rec {
      pname = "markdown-exec";
      version = "1.9.3";
      pyproject = true;

      disabled = pythonOlder "3.8";

      src = fetchFromGitHub {
        owner = "pawamoy";
        repo = "markdown-exec";
        rev = "${version}";
        hash = "sha256-nbS3k4DlYAdrKbidNSKP51gAS/9F3oiHnSGeLMVSjBE=";
      };

      nativeBuildInputs = [
        pdm-backend
      ];

      nativeCheckInputs = [
        pytestCheckHook
      ];

      propagatedBuildInputs = [
        mkdocs
        pymdown-extensions
      ];

      pythonImportsCheck = [
        "markdown_exec"
      ];

      meta = with lib; {
        homepage = "https://github.com/pawamoy/markdown-exec";
        description = "Utilities to execute code blocks in Markdown files";
        changelog = "https://github.com/pawamoy/markdown-exec/releases/v${version}";
        license = licenses.mit;
        maintainers = with maintainers; [aldoborrero];
      };
    })
