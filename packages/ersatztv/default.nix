# Taken from https://github.com/NixOS/nixpkgs/pull/348655/files#diff-8101eeaf792a00b3b797367d5b1a5b21d8e6d15bebb59fab60eaa5aa5bd31a98
{
  pkgs,
  ersatztv-ffmpeg ? pkgs.callPackage ../ersatztv-ffmpeg { },
  ...
}:
with pkgs;
buildDotnetModule rec {
  pname = "ersatztv";
  version = "25.4.0";

  src = fetchFromGitHub {
    owner = "ErsatzTV";
    repo = "ErsatzTV";
    rev = "v${version}";
    sha256 = "sha256-JIfZNp6TpSaC4eOr0a2MK3XXT6uM93eQgQv2x1gAwY0=";
  };

  buildInputs = [ ersatztv-ffmpeg ];

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
