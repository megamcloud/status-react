# This combines builds for multiple architectures into one file

{ lib, stdenv, callPackage, zip, unzip
# Custom flags
, source
, goBuildFlags ? [ ]
, goBuildLdFlags ? [ ]
, enableNimbus ? false
, architectures ? [ "arm" "arm64" "386" ]
, outputFileName ? "status-go-${source.shortRev}.aar" }:

callPackage ../build.nix {
  platform = "android";
  inherit architectures source goBuildFlags goBuildLdFlags outputFileName;
}
