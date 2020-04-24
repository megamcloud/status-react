# This combines builds for multiple architectures into one file

{ lib, stdenv, callPackage, zip, unzip
# Custom flags
, architectures ? [ "arm64" "arm" "386" ]
, goBuildFlags ? [ ]
, goBuildLdFlags ? [ ]
, source ? { }
, enableNimbus ? false
, outputFileName ? "status-go-${source.shortRev}.aar" }:

let
  inherit (lib) substring;

  # Build status-go for architecture provided
  buildForArch = arch:
    callPackage ../build.nix {
      platform = "android";
      inherit arch source goBuildFlags goBuildLdFlags;
    };
in stdenv.mkDerivation {
  pname = source.repo;
  version = "${source.cleanVersion}-${substring 0 7 source.rev}-android";

  # Use builds of status-go for all architectures as sources
  srcs = map buildForArch architectures;

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
}
