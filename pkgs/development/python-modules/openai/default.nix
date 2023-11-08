{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pythonOlder,
  # Build deps
  anyio,
  distro,
  hatchling,
  httpx,
  numpy,
  pandas,
  pandas-stubs,
  pydantic,
  tqdm,
  typing-extensions,
  # Check deps
  pytestCheckHook,
  dirty-equals,
  pytest-asyncio,
  respx,
  withOptionalDependencies ? false,
}:
# see: https://github.com/NixOS/nixpkgs/pull/265946
buildPythonPackage rec {
  pname = "openai";
  version = "1.1.0";
  pyproject = true;

  disabled = pythonOlder "3.7.1";

  src = fetchFromGitHub {
    owner = "openai";
    repo = "openai-python";
    rev = "refs/tags/v${version}";
    hash = "sha256-mGu+Ce4kp5v8W2EIdppqj1KRRWqt9TbamaovB1NGecU=";
  };

  nativeBuildInputs = [hatchling];

  propagatedBuildInputs =
    [
      anyio
      distro
      httpx
      pydantic
      tqdm
      typing-extensions
    ]
    ++ lib.optionals withOptionalDependencies passthru.optional-dependencies.datalib;

  passthru.optional-dependencies = {
    datalib = [
      numpy
      pandas
      pandas-stubs
    ];
  };

  pythonImportsCheck = [
    "openai"
  ];

  nativeCheckInputs = [
    pytestCheckHook
    dirty-equals
    pytest-asyncio
    respx
  ];

  disabledTests = [
    # Tests that seem broken on package end
    "test_azure_api_key_and_version_env"
    "test_azure_api_key_env_without_api_version"
    "test_pydantic_mismatched_object_type"
    "test_pydantic_mismatched_types"
    "test_pydantic_unknown_field"
    "test_raw_response_for_binary"
  ];

  disabledTestPaths = [
    # Tests that require network access
    "tests/api_resources"
  ];

  meta = with lib; {
    description = "Python client library for the OpenAI API";
    homepage = "https://github.com/openai/openai-python";
    changelog = "https://github.com/openai/openai-python/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [malo];
  };
}
