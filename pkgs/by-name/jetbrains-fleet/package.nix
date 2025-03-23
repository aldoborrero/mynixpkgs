{
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  fetchzip,
  fontconfig,
  freetype,
  glib,
  imagemagick,
  lib,
  libGL,
  libX11,
  libXext,
  libXi,
  libXrender,
  libXtst,
  makeDesktopItem,
  mesa,
  stdenv,
  zlib,
}:
stdenv.mkDerivation rec {
  pname = "jetbrains-fleet";
  version = "1.25.206";

  src = fetchzip {
    url = "https://download-cdn.jetbrains.com/fleet/installers/linux_x64/Fleet-${version}.tar.gz";
    sha256 = "sha256-9TyGc4gCkj2ZpawXaJR9ehmALOckPCeg612o/uYrsXI=";
  };

  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    imagemagick
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    fontconfig
    freetype
    glib
    libGL
    libX11
    libXext
    libXi
    libXrender
    libXtst
    mesa
    zlib
  ];

  desktopItems = makeDesktopItem {
    name = "jetbrains-fleet";
    exec = "Fleet";
    icon = "Fleet";
    desktopName = "JetBrains Fleet";
    genericName = "JetBrains Fleet";
    categories = ["Application" "Development" "IDE"];
  };

  installPhase = ''
    runHook preInstall

    # Generate icons from the original 1024x1024 one
    for size in 16 24 32 48 64 128 256 512 1024; do
      mkdir -pv $out/share/icons/hicolor/"$size"x"$size"/apps
      convert -resize "$size"x"$size" $src/lib/Fleet.png $out/share/icons/hicolor/"$size"x"$size"/apps/Fleet.png
    done;

    # Copy binaries and other files
    cp -r $src/* $out

    runHook postInstall
  '';

  meta = with lib; {
    description = "The Next-Generation IDE by Jetbrains";
    homepage = "https://www.jetbrains.com/fleet/";
    license = licenses.unfree;
    mainProgram = "Fleet";
    platforms = ["x86_64-linux"];
    maintainers = with maintainers; [aldoborrero];
  };
}
