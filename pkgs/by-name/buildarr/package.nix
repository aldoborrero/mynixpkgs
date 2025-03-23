{python312Packages}:
python312Packages.callPackage ({
    aenum,
    buildPythonPackage,
    click,
    click-params,
    fetchFromGitHub,
    importlib-metadata,
    lib,
    pydantic,
    pytestCheckHook,
    pythonOlder,
    pyyaml,
    requests,
    schedule,
    stevedore,
    typing-extensions,
    watchdog,
  }:
    buildPythonPackage rec {
      pname = "buildarr";
      version = "0.7.1";
      pyproject = true;

      disabled = pythonOlder "3.8";

      src = fetchFromGitHub {
        owner = "buildarr";
        repo = "buildarr";
        rev = "v${version}";
        hash = "";
      };

      nativeCheckInputs = [
        pytestCheckHook
      ];

      propagatedBuildInputs = [
        aenum
        click
        click-params
        importlib-metadata
        pyyaml
        pydantic
        requests
        schedule
        stevedore
        typing-extensions
        watchdog
      ];

      pythonImportsCheck = [
        "buildarr"
      ];

      meta = with lib; {
        homepage = "https://github.com/buildarr/buildarr";
        description = "Constructs and configures Arr PVR stacks";
        changelog = "https://github.com/buildarr/buildarr/releases/v${version}";
        license = licenses.gpl3;
        maintainers = with maintainers; [aldoborrero];
      };
    })
