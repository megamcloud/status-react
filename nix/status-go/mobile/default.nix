{ callPackage, source, goBuildFlags, goBuildLdFlags }:

{
  android = callPackage ./build.nix {
    platform = "android";
    architectures = [ "arm" "arm64" "386" ];
    outputFileName = "status-go-${source.shortRev}.aar";
    inherit source goBuildFlags goBuildLdFlags;
  };

  ios = callPackage ./build.nix {
    platform = "ios";
    architectures = [ "arm" "arm64" "386" ];
    outputFileName = "Statusgo.framework";
    inherit source goBuildFlags goBuildLdFlags;
  };
}
