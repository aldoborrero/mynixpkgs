{
  lib,
  buildGoModule,
  fetchFromGitHub,
  atlas,
}:
buildGoModule rec {
  pname = "digger-backend";
  version = "0.6.71";

  src = fetchFromGitHub {
    owner = "diggerhq";
    repo = "digger";
    rev = "v${version}";
    hash = "sha256-npid5q3eHRQSJt8rKQ/PVQh5qBIz2V3mzAkCWz/VrrE=";
  };

  vendorHash = "sha256-qcItUM2wQ4fgFDMGkyymxQugGaRQvn7rrmSzaLtL76Q=";
  proxyVendor = true;

  CGO_ENABLED = 0;

  nativeBuildInputs = [atlas];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  subPackages = ["backend"];

  postInstall = ''
    mkdir -p $out/share/digger-backend
    cp -r $src/backend/templates $out/share/digger-backend/
    cp -r $src/backend/migrations $out/share/digger-backend/
    mv $out/bin/backend $out/bin/digger-backend
  '';

  meta = with lib; {
    description = "Backend service for Digger, an open source IaC orchestration tool";
    homepage = "https://github.com/diggerhq/digger";
    license = licenses.asl20;
    mainProgram = "digger-backend";
    maintainers = with maintainers; [aldoborrero];
  };
}
