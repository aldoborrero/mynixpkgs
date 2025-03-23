{
  buildGo122Module,
  fetchFromGitHub,
  lib,
}:
buildGo122Module rec {
  pname = "cueimports";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "asdine";
    repo = "cueimports";
    rev = "v${version}";
    hash = "sha256-ZVbc4Jp1j2/8EPHYW+btKbuzNRulC2IaAPbz37R60Og=";
  };

  vendorHash = "sha256-YJkbWuOO5sVQTYFwzmd30r7kMFxCVTmtkVTUmeZkkx8=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = ["cmd/cueimports"];

  meta = with lib; {
    description = "CUE tool that updates your import lines, adding missing ones and removing unused ones.";
    homepage = "https://github.com/asdine/cueimports";
    license = licenses.mit;
    maintainers = with maintainers; [aldoborrero];
    mainProgram = "cueimports";
  };
}
