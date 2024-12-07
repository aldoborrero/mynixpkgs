{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "digger-cli";
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

  ldflags = [
    "-s"
    "-w"
    "-X digger/pkg/utils.version=${version}"
  ];

  subPackages = ["cli/cmd/digger"];

  meta = with lib; {
    description = "Digger is an open source IaC orchestration tool. Digger allows you to run IaC in your existing CI pipeline";
    homepage = "https://github.com/diggerhq/digger";
    license = licenses.asl20;
    mainProgram = "digger";
    maintainers = with maintainers; [aldoborrero];
  };
}
