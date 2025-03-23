{
  buildGo123Module,
  fetchFromGitHub,
  lib,
}:
buildGo123Module rec {
  pname = "helm-schema";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "dadav";
    repo = "helm-schema";
    rev = "${version}";
    hash = "sha256-mO6K/ZOIW6fpy/0NIkuqwn27c4dbgHRopdcei8rBj3I=";
  };

  vendorHash = "sha256-q0Z0mmG5KGB3EZNkW8NhmSvNcap3/dBGMOu4pERhTzE=";

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  subPackages = ["cmd/helm-schema"];

  meta = with lib; {
    description = "Generate jsonschemas from helm charts";
    homepage = "https://github.com/dadav/helm-schema";
    license = licenses.mit;
    maintainers = with maintainers; [aldoborrero];
  };
}
