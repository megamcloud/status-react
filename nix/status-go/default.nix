{ stdenv, callPackage, mkShell, mergeSh, openjdk, androidPkgs }:

let
  inherit (stdenv.lib)
    catAttrs concatStrings concatStringsSep fileContents makeBinPath
    optional optionalString attrValues mapAttrs attrByPath;

  envFlags = callPackage ../tools/envParser.nix { };
  enableNimbus = (attrByPath ["STATUS_GO_ENABLE_NIMBUS"] "0" envFlags) != "0";

  #desktop = rec {
  #  buildInputs = [ status-go-packages.desktop ];
  #  shell = mkShell {
  #    inherit buildInputs;
  #    shellHook = ''
  #      # These variables are used by the Status Desktop CMake build script in modules/react-native-status/desktop/CMakeLists.txt
  #      export STATUS_GO_DESKTOP_INCLUDEDIR=${status-go-packages.desktop}/include
  #      export STATUS_GO_DESKTOP_LIBDIR=${status-go-packages.desktop}/lib
  #    '';
  #  };
  #};
  #platforms = [ android ios desktop ];

  meta = {
    description = "The Status module that consumes go-ethereum.";
    license = stdenv.lib.licenses.mpl20;
    platforms = with stdenv.lib.platforms; linux ++ darwin;
  };

  nimbus =
    if enableNimbus then callPackage ./nimbus { }
    else { wrappers-android = { }; };

  # source can be changed with a local override
  source = callPackage ./source.nix { };

  goBuildFlags = [ "-v" (optionalString enableNimbus "-tags='nimbus'") ];

  # status-go params to be set at build time, important for About section and metrics
  goBuildParams = {
    GitCommit = source.rev;
    Version = source.cleanVersion;
  };
  # These are necessary for status-go to show correct version
  paramsLdFlags = attrValues (mapAttrs (name: value:
    "-X github.com/status-im/status-go/params.${name}=${value}"
  ) goBuildParams);

  goBuildLdFlags = paramsLdFlags ++ [
    "-s" # -s disabled symbol table
    "-w" # -w disables DWARF debugging information
  ];

in {
  desktop = callPackage ./desktop {
    inherit meta source goBuildFlags goBuildLdFlags;
  };

  mobile = callPackage ./mobile {
    inherit meta source goBuildFlags goBuildLdFlags;
  };

  #shell = mergeSh mkShell {
  #  buildInputs = ;
  #  shellHook = ''
  #  '';
  #};
}
