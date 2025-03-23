{
  lib,
  python3Packages,
  fetchFromGitHub,
  openai,
  ffmpeg_4,
}:
python3Packages.buildPythonApplication rec {
  pname = "ospeak";
  version = "0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonw";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-OD4NZAKWkco/BMiU19FZFLFdrWUCvUKe/hk83K3yDkc=";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    click-default-group
    openai
    pydub
  ];

  nativeCheckInputs = with python3Packages; [
    cogapp
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "ospeak"
  ];

  postInstall = ''
    wrapProgram $out/bin/ospeak \
      --prefix PATH : ${lib.makeBinPath [ffmpeg_4]}
  '';

  meta = with lib; {
    homepage = "https://github.com/simonw/ospeak";
    description = "CLI tool for running text through OpenAI Text to speech";
    changelog = "https://github.com/simonw/ospeak/releases/tag/${version}";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [aldoborrero];
  };
}
