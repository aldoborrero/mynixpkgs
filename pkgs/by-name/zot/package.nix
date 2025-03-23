{
  buildGoModule,
  fetchFromGitHub,
  lib,
  go,
}:
buildGoModule rec {
  pname = "zot";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "project-zot";
    repo = "zot";
    rev = "v${version}";
    hash = "sha256-gM6niHLWE4Cr6FwyIvcke/JM/PPrKpXQjpSpjgz6BUI=";
  };

  env.CGO_ENABLED = 0;

  vendorHash = "sha256-f6SUgv2tCzNfLG0j2lqHPTBk7hr9J/celEF1OCpiSIU=";

  extensions = "sync,search,scrub,metrics,lint,ui,mgmt,profile,userprefs,imagetrust";

  ldflags = [
    "-X zotregistry.dev/zot/pkg/api/config.ReleaseTag=${version}"
    "-X zotregistry.dev/zot/pkg/api/config.Commit=${src.rev}"
    "-X zotregistry.dev/zot/pkg/api/config.BinaryType=${lib.replaceStrings [","] ["-"] extensions}"
    "-X zotregistry.dev/zot/pkg/api/config.GoVersion=${lib.getVersion go}"
    "-s"
    "-w"
  ];

  subPackages = [
    "cmd/zot"
  ];

  doCheck = false;

  meta = {
    description = "zot - A production-ready vendor-neutral OCI-native container image/artifact registry (purely based on OCI Distribution Specification)";
    homepage = "https://github.com/project-zot/zot";
    mainProgram = "zot";
    platforms = ["x86_64-linux"];
  };
}
