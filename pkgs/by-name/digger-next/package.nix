{
  fetchFromGitHub,
  lib,
  nodejs_20,
  openssl,
  pnpm_9,
  prisma,
  prisma-engines,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "digger-next";
  version = "0.1.0-dev";

  src = fetchFromGitHub {
    owner = "diggerhq";
    repo = "next";
    rev = "main";
    sha256 = "sha256-m1SuF6wWzPNuANOiLo00hX2p+MHLdP8IV8iC+/jndlE=";
  };

  nativeBuildInputs = [
    nodejs_20
    openssl
    pnpm_9.configHook
    prisma
    prisma-engines
  ];

  pnpmDeps = pnpm_9.fetchDeps {
    inherit pname version src;
    hash = "sha256-w69mk6LjGEgFUtCEVudpld5UJGGKfY6BRqKMajR6fwA=";
  };

  env = {
    DATABASE_URL = "postgresql://";
    PRISMA_SCHEMA_ENGINE_BINARY = "${prisma-engines}/bin/schema-engine";
    PRISMA_QUERY_ENGINE_BINARY = "${prisma-engines}/bin/query-engine";
    PRISMA_QUERY_ENGINE_LIBRARY = "${prisma-engines}/lib/libquery_engine.node";
    PRISMA_INTROSPECTION_ENGINE_BINARY = "${prisma-engines}/bin/introspection-engine";
    PRISMA_FMT_BINARY = "${prisma-engines}/bin/prisma-fmt";
    PRISMA_CLI_QUERY_ENGINE_TYPE = "binary";
  };

  preBuildPhase = ''
    export HOME=$(mktemp -d)
  '';

  buildPhase = ''
    runHook preBuild

    prisma generate --generator client {
      provider = "prisma-client-js"
      previewFeatures = ["clientExtensions", "sql"]
    }

    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/${pname}
    cp -r . $out/lib/node_modules/${pname}

    mkdir -p $out/bin
    cat > $out/bin/${pname} <<EOF
    #!${stdenv.shell}
    exec ${nodejs_20}/bin/node $out/lib/node_modules/${pname}/server.js
    EOF
    chmod +x $out/bin/${pname}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Digger Next.js Application";
    homepage = "https://github.com/diggerhq/next";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [aldoborrero];
    mainProgram = "digger-next";
  };
}
