{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "chartify";
  version = "0.20.3";

  src = fetchFromGitHub {
    owner = "helmfile";
    repo = "chartify";
    rev = "v${version}";
    hash = "sha256-bRXCU4Fx/5UV/VhLvujYYdkWUdVzDZxOaMkb0P/ZtDc=";
  };

  vendorHash = "sha256-Mp8XGxIn7VTzJDVweOtBBe2hSJIOWabMW0bZjsXJ5WA=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [
    "cmd/chartify"
    "cmd/chartreposerver"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Convert K8s manifests/Kustomization into Helm Chart";
    homepage = "https://github.com/helmfile/chartify";
    license = licenses.asl20;
    maintainers = with maintainers; [aldoborrero];
    mainProgram = "chartify";
  };
}
