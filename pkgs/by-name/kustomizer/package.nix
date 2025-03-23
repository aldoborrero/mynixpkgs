{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "kustomizer";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "stefanprodan";
    repo = "kustomizer";
    rev = "v${version}";
    hash = "sha256-/HNjBNUGueVRIn8rgvx03nTXF1mJSj/nptoP8/AecSM=";
  };

  vendorHash = "sha256-xGK2JTl/pmG4V85XAZY4PlKIk3bZUJ5mwipAGjS9miw=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = ["cmd/kustomizer"];

  doCheck = false;

  meta = with lib; {
    description = "An experimental package manager for distributing Kubernetes configuration as OCI artifacts";
    homepage = "https://github.com/stefanprodan/kustomizer";
    license = licenses.asl20;
    maintainers = with maintainers; [aldoborrero];
    mainProgram = "kustomizer";
  };
}
