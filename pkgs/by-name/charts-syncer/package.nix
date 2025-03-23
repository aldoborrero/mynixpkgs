{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "charts-syncer";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "bitnami";
    repo = "charts-syncer";
    rev = "v${version}";
    hash = "sha256-Sgq6YtWHLnmd7zove9sxYc/9YceADS0fxzTo/klAg+k=";
  };

  vendorHash = "sha256-pScLsCOLV4lYnovFMaf3wRuGXn6um1UlsQn4DVLKDFM=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = ["cmd"];

  postInstall = ''
    mv $out/bin/cmd $out/bin/charts-syncer
  '';

  doCheck = false;

  meta = with lib; {
    description = "Tool for synchronizing Helm Chart repositories.";
    homepage = "https://github.com/bitnami/charts-syncer";
    license = licenses.mit;
    maintainers = with maintainers; [aldoborrero];
    mainProgram = "charts-syncer";
  };
}
