{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm,
  makeWrapper,
  prisma-engines,
  google-fonts,
}:
stdenv.mkDerivation rec {
  pname = "split-pro";
  version = "1.2.29";

  src = fetchFromGitHub {
    owner = "oss-apps";
    repo = "split-pro";
    rev = "v${version}";
    sha256 = "sha256-DqnkJzlXMg3bIHjf8IcoI1wDsKZ7TexOMtJM4m26cz8=";
  };

  patches = [
    ./use-system-fonts.patch
  ];

  nativeBuildInputs = [
    makeWrapper
    nodejs
    pnpm.configHook
    prisma-engines
  ];

  buildInputs = [
    (google-fonts.override {fonts = ["Poppins"];})
  ];

  pnpmDeps = pnpm.fetchDeps {
    inherit pname version src;
    hash = "sha256-99gKtUTLo6C4EsvBZzH4wZNIKZhNwTreuTaEBYO5EaM=";
  };

  # Build-time environment variables
  DOCKER_OUTPUT = "1";
  NEXT_TELEMETRY_DISABLED = "1";
  NODE_ENV = "development";
  SKIP_ENV_VALIDATION = "true";

  PRISMA_FETCH_ENGINE_BINARY = "${prisma-engines}/bin/fetch-engine";
  PRISMA_FMT_BINARY = "${prisma-engines}/bin/prisma-fmt";
  PRISMA_QUERY_ENGINE_BINARY = "${prisma-engines}/bin/query-engine";
  PRISMA_QUERY_ENGINE_LIBRARY = "${prisma-engines}/lib/libquery_engine.node";
  PRISMA_SCHEMA_ENGINE_BINARY = "${prisma-engines}/bin/schema-engine";

  buildPhase = ''
    runHook preBuild

    # Install all dependencies including devDependencies
    pnpm install --ignore-scripts

    # Generate Prisma client
    node node_modules/prisma/build/index.js generate

    # Set production mode for build
    export NODE_ENV=production

    # Build the application
    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Create target directory
    mkdir -p $out/share/split-pro

    # Copy built files, following Docker's standalone output pattern
    cp -r .next/standalone/. $out/share/split-pro/
    cp -r .next/static $out/share/split-pro/.next/
    cp -r public $out/share/split-pro/

    # Copy Prisma files
    mkdir -p $out/share/split-pro/prisma
    cp prisma/schema.prisma $out/share/split-pro/prisma/
    cp -r prisma/migrations $out/share/split-pro/prisma/

    # Copy necessary node_modules
    mkdir -p $out/share/split-pro/node_modules
    cp -r node_modules/prisma $out/share/split-pro/node_modules/
    cp -r node_modules/@prisma $out/share/split-pro/node_modules/
    cp -r node_modules/sharp $out/share/split-pro/node_modules/

    # Create wrapper script
    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/split-pro \
      --add-flags "$out/share/split-pro/server.js" \
      --set NODE_ENV production \
      --set SKIP_ENV_VALIDATION "false" \
      --set NEXT_TELEMETRY_DISABLED "1" \
      --set PRISMA_QUERY_ENGINE_BINARY "${prisma-engines}/bin/query-engine" \
      --set PRISMA_QUERY_ENGINE_LIBRARY "${prisma-engines}/lib/libquery_engine.node" \
      --set PRISMA_SCHEMA_ENGINE_BINARY "${prisma-engines}/bin/schema-engine" \
      --set PRISMA_FETCH_ENGINE_BINARY "${prisma-engines}/bin/fetch-engine" \
      --set PRISMA_FMT_BINARY "${prisma-engines}/bin/prisma-fmt" \
      --prefix PATH : "${lib.makeBinPath [nodejs prisma-engines]}:$out/share/split-pro/node_modules/.bin"

    runHook postInstall
  '';

  meta = with lib; {
    description = "An open source alternative to Splitwise";
    homepage = "https://github.com/oss-apps/split-pro";
    license = licenses.mit;
    mainProgram = "split-pro";
    maintainers = with maintainers; [aldoborrero];
    platforms = platforms.linux;
  };
}
