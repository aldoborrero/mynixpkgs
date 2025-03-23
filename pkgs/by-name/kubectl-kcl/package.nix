{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "kubectl-kcl";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "kcl-lang";
    repo = "kubectl-kcl";
    rev = "v${version}";
    hash = "sha256-yuNQSO1xQCb5H55mOUTVrojeWWkDOmAGJIzUs6qCWO4=";
  };

  vendorHash = "sha256-GD4C4jlxVMpJ/bhpQ3VDkBMBBQkXyhMMga+WhVdvI/I=";

  subPackages = ["."];

  meta = with lib; {
    description = "Kubectl KCL Plugin";
    homepage = "https://github.com/kcl-lang/kubectl-kcl";
    license = licenses.asl20;
    maintainers = with maintainers; [aldoborrero];
    platforms = platforms.unix;
  };
}
