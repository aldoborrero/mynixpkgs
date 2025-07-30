{
  lib,
  stdenv,
  ffmpeg-full,
  # Hardware acceleration libraries
  intel-media-driver,
  intel-vaapi-driver,
  # CUDA support (optional)
  cudaSupport ? false,
}: let
  version = "7.1.1";
in
  (ffmpeg-full.override {
    inherit version; # Ensure we're using the correct version

    # Disable ffplay (ErsatzTV doesn't need it)
    buildFfplay = false;

    # Enable small build optimizations
    withSmallBuild = true;
    withStripping = true;

    # Essential codecs that ErsatzTV specifically enables
    withAom = true; # --enable-libaom (AV1)
    withDav1d = true; # --enable-libdav1d (AV1 decoder)
    withAss = true; # --enable-libass (subtitles)
    withFdkAac = true; # --enable-libfdk_aac
    withKvazaar = true; # --enable-libkvazaar (HEVC)
    withMp3lame = true; # --enable-libmp3lame (MP3 encoding)
    withOpencoreAmrnb = true; # --enable-libopencore-amrnb
    withOpencoreAmrwb = true; # --enable-libopencore-amrwb
    withOpenjpeg = true; # --enable-libopenjpeg (JPEG 2000)
    withOpus = true; # --enable-libopus
    withSrt = true; # --enable-libsrt
    withTheora = true; # --enable-libtheora
    withVorbis = true; # --enable-libvorbis
    withVpx = true; # --enable-libvpx
    withWebp = true; # --enable-libwebp
    withX264 = true; # --enable-libx264
    withX265 = true; # --enable-libx265
    withXvid = true; # --enable-libxvid
    withZimg = true; # --enable-libzimg

    # Video processing libraries
    withPlacebo = true; # --enable-libplacebo (GPU processing)
    withShaderc = true; # --enable-libshaderc (Vulkan shaders)

    # Font and text support (ErsatzTV explicitly enables these)
    withFontconfig = true; # --enable-fontconfig, --enable-libfontconfig
    withFreetype = true; # --enable-libfreetype
    withFribidi = true; # --enable-libfribidi

    # System integration
    withV4l2 = true; # --enable-libv4l2 (Video4Linux)
    withXml2 = true; # --enable-libxml2

    # Network - ErsatzTV uses OpenSSL, but nixpkgs FFmpeg may have different SSL handling
    withGnutls = true; # Keep enabled for SSL support

    # Ensure hardware acceleration is enabled
    withVaapi = true; # Intel/AMD VA-API
    withVdpau = true; # NVIDIA/AMD VDPAU
    withVulkan = true; # Vulkan API
    withOpencl = true; # OpenCL
    withVpl = true; # Intel VPL

    # CUDA support (conditional)
    withCuda = cudaSupport;
    withCudaLLVM = cudaSupport;
    withCudaNVCC = cudaSupport && stdenv.isLinux && stdenv.isx86_64;
    withCuvid = cudaSupport;
    withNvdec = cudaSupport;
    withNvenc = cudaSupport;
    withNpp = cudaSupport;

    # Ensure licensing allows all features
    withGPL = true;
    withVersion3 = true;
    withUnfree = true;

    # Disable conflicting features
    withMfx = false; # Conflicts with libvpl
  }).overrideAttrs (old: {
    pname = "erstaztv-ffmpeg";

    # Add additional Intel hardware acceleration drivers
    buildInputs =
      old.buildInputs
      ++ lib.optionals (!cudaSupport && stdenv.isLinux) [
        intel-media-driver
        intel-vaapi-driver
      ];

    meta =
      old.meta
      // {
        description = "${old.meta.description} (ErsatzTV optimized build)";
        homepage = "https://github.com/ErsatzTV/ErsatzTV-ffmpeg";
        platforms = lib.platforms.linux;
        maintainers = with lib.maintainers; [aldoborrero];
      };
  })
