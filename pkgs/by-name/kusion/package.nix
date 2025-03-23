{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "kusion";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "KusionStack";
    repo = "kusion";
    rev = "v${version}";
    hash = "sha256-5qrSMgK7I/m+zUMv4U2lyGoe4FX5mkKLlvlORTGnZ2U=";
  };

  vendorHash = "sha256-oFp+KUIYi82Crn58xEuIAT6s5zTUpHanzhn482j3+EE=";

  subPackages = ["kusion.go"];

  meta = with lib; {
    description = "KusionStack's cloud-native application configuration and deployment tool";
    homepage = "https://github.com/KusionStack/kusion";
    license = licenses.asl20;
    maintainers = with maintainers; [aldoborrero];
    platforms = platforms.unix;
  };
}
