# Taken from https://github.com/NixOS/nixpkgs/pull/348655/files#diff-8101eeaf792a00b3b797367d5b1a5b21d8e6d15bebb59fab60eaa5aa5bd31a98
{
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
  ersatztv-ffmpeg,
  lib,
  libva-utils,
  which,
}:
buildDotnetModule rec {
  pname = "ersatztv";
  version = "25.3.1";

  src = fetchFromGitHub {
    owner = "ErsatzTV";
    repo = "ErsatzTV";
    rev = "v${version}";
    sha256 = "sha256-HyRVDsmkJSLgn9wff0/GeFELqTNyDY1D5z+tJ5d6UPA=";
  };

  buildInputs = [ersatztv-ffmpeg];

  projectFile = "ErsatzTV/ErsatzTV.csproj";
  executables = [
    "ErsatzTV"
    "ErsatzTV.Scanner"
  ];
  nugetDeps = ./nuget-deps.nix;
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_9_0;

  # ETV uses `which` to find `ffmpeg` and `ffprobe`
  makeWrapperArgs = [
    "--suffix"
    "PATH"
    ":"
    "${lib.makeBinPath [
      ersatztv-ffmpeg
      libva-utils
      which
    ]}"
  ];

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Configuring and streaming custom live channels using your media library";
    homepage = "https://ersatztv.org/";
    license = licenses.zlib;
    mainProgram = "ErsatzTV";
    inherit (dotnet-runtime.meta) platforms;
  };
}
