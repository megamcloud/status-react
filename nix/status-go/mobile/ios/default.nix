{ lib, stdenv, callPackage, zip, unzip,
  goBuildFlags ? [],
  goBuildLdFlags ? [],
  source ? { },
  enableNimbus ? false
, architectures ? [ "ios" ] }:

let
  inherit (lib) substring concatStrings mapAttrsToList;

  # Architectures viable for status-go builds
  platformArchs = {
    android = [ "arm64" "arm" "386" ];
  };


  #nimbus = nimbus.wrappers-android.arm64;
  #nimbus = nimbus.wrappers-android.arm;
  #nimbus = nimbus.wrappers-android.x86;
in
  callPackage ../build.nix {
    outputFileName = "Statusgo.framework";
    inherit platform arch source goBuildFlags goBuildLdFlags;
  }
