{
  buildGoModule,
  lib,
  fetchFromGitHub,
  protobuf,
  protoc-gen-go,
  protoc-gen-go-grpc,
  pkg-config,
  vips,
}:
buildGoModule rec {
  pname = "gows";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "devlikeapro";
    repo = "gows";
    rev = "v${version}";
    hash = "sha256-RAFeenxWyYLOr1R703SnwBeICi9sXjDF/as77p+q4/c=";
  };

  sourceRoot = "source/src";

  vendorHash = "sha256-Q8hBl6gsLPl4SwZkSOSMM5CbufzSEc+xZdNfSCRJc8c=";

  nativeBuildInputs = [
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc
    pkg-config
  ];

  buildInputs = [
    vips
  ];

  env.PKG_CONFIG_PATH = "${vips.dev}/lib/pkgconfig";

  preBuild = ''
    cd ..
    mkdir -p src/proto

    protoc \
      -I=. \
      --go_out=./src/proto \
      --go-grpc_out=./src/proto \
      proto/*.proto

    cd src
  '';

  subPackages = ["main.go"];

  postInstall = ''
    mv $out/bin/main $out/bin/gows
  '';

  meta = with lib; {
    description = "Go WebSocket implementation for WhatsApp API";
    homepage = "https://github.com/devlikeapro/gows";
    license = licenses.unlicense;
    maintainers = with maintainers; [aldoborrero];
    platforms = platforms.linux;
  };
}
