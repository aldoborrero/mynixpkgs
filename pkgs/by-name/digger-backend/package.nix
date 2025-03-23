{
  atlas,
  buildGoModule,
  lib,
  digger-src,
}:
buildGoModule rec {
  pname = "digger-backend";
  version = "0.6.87";

  src = digger-src;

  vendorHash = "sha256-fjX4iqrlWkuZrEOOfgEmDpqHs8qMrH9ZupLSzzFM7qo=";
  proxyVendor = true;

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  subPackages = ["backend"];

  patches = [
    ./001-hostname.patch
    ./002-goose-migrations.patch
  ];

  postInstall = ''
    mv $out/bin/backend $out/bin/digger-backend

    # copy migrations
    mkdir -p $out/share/
    cp -r backend/{migrations,goose-migrations} $out/share/
    cp -r backend/templates $out/share/
  '';

  passthru = {inherit atlas;};

  meta = with lib; {
    description = "Backend service for Digger, an open source IaC orchestration tool";
    homepage = "https://github.com/diggerhq/digger";
    license = licenses.asl20;
    mainProgram = "digger-backend";
    maintainers = with maintainers; [aldoborrero];
  };
}
