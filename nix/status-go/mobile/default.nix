{ lib, stdenv, callPackage, zip, unzip,
  goBuildFlags ? [],
  goBuildLdFlags ? [],
  source ? { },
  platform ? "android",
  enableNimbus ? false }:

let
  inherit (lib) substring concatStrings mapAttrsToList;

  # Architectures viable for status-go builds
  platformArchs = {
    android = [ "arm64" "arm" "386" ];
    ios = [ "ios" ];
  };

  # Build status-go for architecture provided
  buildArch = arch:
    callPackage ./build.nix {
      inherit platform arch source goBuildFlags goBuildLdFlags;
    };

  # Build status-go for all architectures
  archBuilds = map (arch: buildArch arch) platformArchs.${platform};
  #nimbus = nimbus.wrappers-android.arm64;
  #nimbus = nimbus.wrappers-android.arm;
  #nimbus = nimbus.wrappers-android.x86;

  outputFileName = 
    if platform == "ios" then "Statusgo.framework"
    else "status-go-${source.shortRev}.aar";
in
  stdenv.mkDerivation {
    pname = source.repo;
    version = "${source.cleanVersion}-${substring 0 7 source.rev}-${platform}";

    srcs = archBuilds;

    unpackPhase = ''
      runHook preUnpack
      mkdir archs
      for _src in $srcs; do
        ln -s $_src/*.aar ./archs/
      done
      runHook postUnpack
    '';

    # Merge the platform-specific .aar files into a single one
    buildPhase = ''
      local mergeDir='.aar'
      mkdir $mergeDir

      for archive in ./archs/*; do
        echo "Unpacking: $archive"
        ${unzip}/bin/unzip -d $mergeDir -q -n -u $archive
      done

      pushd $mergeDir > /dev/null
        ${zip}/bin/zip -r -o ../${outputFileName} *
      popd > /dev/null
      rm -rf $mergeDir
      ${unzip}/bin/unzip -l ${outputFileName}
    '';

    installPhase = ''
      mkdir -p $out
      mv ${outputFileName} $out/
    '';
    # TODO: Merge iOS packages when linking with libnimbus.a
  }
