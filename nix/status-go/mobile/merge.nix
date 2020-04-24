{ mkDerivation }:

let
in mkDerivation {
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
