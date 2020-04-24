{ enableNimbus ? false }:

let
  mobileConfigs = {
    android = rec {
      name = "android";
      outputFileName = "status-go-${source.shortRev}.aar";
      platforms = {
        arm64 = {
          linkNimbus = enableNimbus;
          nimbus = assert enableNimbus; nimbus.wrappers-android.arm64;
          gomobileTarget = "${name}/arm64";
          outputFileName = "status-go-${source.shortRev}-arm64.aar";
        };
        arm = {
          linkNimbus = enableNimbus;
          nimbus = assert enableNimbus; nimbus.wrappers-android.arm;
          gomobileTarget = "${name}/arm";
          outputFileName = "status-go-${source.shortRev}-arm.aar";
        };
        x86 = {
          linkNimbus = enableNimbus;
          nimbus = assert enableNimbus; nimbus.wrappers-android.x86;
          gomobileTarget = "${name}/386";
          outputFileName = "status-go-${source.shortRev}-386.aar";
        };
      };
    };
    ios = rec {
      name = "ios";
      outputFileName = "Statusgo.framework";
      platforms = {
        ios = {
          linkNimbus = enableNimbus;
          nimbus = assert false; null; # TODO: Currently we don't support Nimbus on iOS
          gomobileTarget = name;
          inherit outputFileName;
        };
      };
    };
  };
in
