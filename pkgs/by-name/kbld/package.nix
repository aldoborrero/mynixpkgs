{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "kbld";
  version = "0.44.1";

  src = fetchFromGitHub {
    owner = "carvel-dev";
    repo = "kbld";
    rev = "v${version}";
    hash = "sha256-sEzCA32r3nSY1hT1r4EPPWsF9Kgn0rXnaAKlatFjZIo=";
  };

  vendorHash = null;

  subPackages = ["cmd/kbld"];

  meta = with lib; {
    description = "Carvel tool for building, pushing and referencing container images in Kubernetes configuration files";
    homepage = "https://github.com/carvel-dev/kbld";
    license = licenses.asl20;
    maintainers = with maintainers; [aldoborrero];
    platforms = platforms.unix;
  };
}
