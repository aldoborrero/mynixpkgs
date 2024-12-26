# Taken from https://github.com/NixOS/nixpkgs/pull/348655/files#diff-8101eeaf792a00b3b797367d5b1a5b21d8e6d15bebb59fab60eaa5aa5bd31a98
{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  ffmpeg,
  lib,
  libva-utils,
  which,
}:
buildDotnetModule rec {
  pname = "ersatztv";
  version = "0.8.8-beta";

  src = fetchFromGitHub {
    owner = "ErsatzTV";
    repo = "ErsatzTV";
    rev = "v${version}";
    sha256 = "sha256-kXAJLM5PeLZH98oasynXfurN+Gyy+9XffpcGtSijiDs=";
  };

  buildInputs = [ffmpeg];

  projectFile = "ErsatzTV/ErsatzTV.csproj";
  executables = [
    "ErsatzTV"
    "ErsatzTV.Scanner"
  ];
  nugetDeps = ./nuget-deps.nix;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;

  # ETV uses `which` to find `ffmpeg` and `ffprobe`
  makeWrapperArgs = [
    "--suffix"
    "PATH"
    ":"
    "${lib.makeBinPath [
      ffmpeg
      libva-utils
      which
    ]}"
  ];

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Configuring and streaming custom live channels using your media library";
    homepage = "https://ersatztv.org/";
    license = licenses.zlib;
    maintainers = with maintainers; [allout58];
    mainProgram = "ErsatzTV";
    inherit (dotnet-runtime.meta) platforms;
  };
}
