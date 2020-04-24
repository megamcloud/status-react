{ platform ? "android",
  enableNimbus ? false }:

let
  mobileConfigs = {
    android = rec {
      platform = "android";
      architectures = {
        arm64 = {
          #nimbus = enableNimbus; nimbus.wrappers-android.arm64;
          outputFileName = "status-go-${source.shortRev}-arm64.aar";
        };
        arm = {
          #nimbus = assert enableNimbus; nimbus.wrappers-android.arm;
          outputFileName = "status-go-${source.shortRev}-arm.aar";
        };
        x86 = {
          #nimbus = assert enableNimbus; nimbus.wrappers-android.x86;
          outputFileName = "status-go-${source.shortRev}-386.aar";
        };
      };
    };
    ios = rec {
      platform = "ios";
      outputFileName = "Statusgo.framework";
      platforms = {
        ios = {
          linkNimbus = enableNimbus;
          nimbus = assert false; null; # TODO: Currently we don't support Nimbus on iOS
          gomobileTarget = name;
        };
      };
    };
  };
in
  mkDerivation {
    name = ;
    buildInputs = [ ];

    # Merge the platform-specific .aar files into a single one
    buildPhase = ''
      local mergeDir='.aar'
      mkdir $mergeDir
      ${
        concatStrings (mapAttrsToList (_: platformConfig: ''
          unzip -d $mergeDir -q -n -u ${platformConfig.outputFileName}
          rm ${platformConfig.outputFileName}
        '') targetConfig.platforms)
      }
      pushd $mergeDir > /dev/null
        zip -r -o ../${targetConfig.outputFileName} *
      popd > /dev/null
      rm -rf $mergeDir
      unzip -l ${targetConfig.outputFileName}
    '';
    # TODO: Merge iOS packages when linking with libnimbus.a
  }
