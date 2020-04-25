{ lib, stdenv, callPackage, zip, unzip
, source
, goBuildFlags ? [ ]
, goBuildLdFlags ? [ ]
, architectures ? [ "arm" "arm64" "386" ]
, outputFileName ? "Statusgo.framework" }:

callPackage ../build.nix {
  platform = "ios";
  inherit architectures source goBuildFlags goBuildLdFlags outputFileName;
}
