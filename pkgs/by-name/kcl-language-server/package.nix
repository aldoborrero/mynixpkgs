{
  lib,
  rustPlatform,
  fetchFromGitHub,
  protobuf,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "kcl-language-server";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "kcl-lang";
    repo = "kcl";
    rev = "v${version}";
    hash = "sha256-14yFGa8y8w3wbCmx0JOSN0TShXLZZpTdVynEfUKkjuE=";
  };

  sourceRoot = "source/kclvm";

  cargoHash = "sha256-o7YFyqRWAMjq23mcAqDrcN4infdBgp1KNvviYOLR35s=";

  nativeBuildInputs = [
    pkg-config
    protobuf
  ];

  buildAndTestSubdir = "tools/src/LSP";

  buildPhaseCargoFlags = [
    "--profile"
    "release"
    "--offline"
  ];

  doCheck = false;

  PROTOC = "${protobuf}/bin/protoc";
  PROTOC_INCLUDE = "${protobuf}/include";

  meta = with lib; {
    description = "A high-performance implementation of KCL written in Rust that uses LLVM as the compiler backend";
    homepage = "https://github.com/kcl-lang/kcl";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [selfuryon peefy];
    mainProgram = "kcl-language-server";
  };
}
