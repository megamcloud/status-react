{ stdenv, callPackage, mkShell, mergeSh, openjdk, androidPkgs }:

let
  inherit (stdenv.lib)
    catAttrs concatStrings concatStringsSep fileContents makeBinPath
    optional optionalString attrValues mapAttrs attrByPath;

  envFlags = callPackage ../tools/envParser.nix { };
  enableNimbus = (attrByPath ["STATUS_GO_ENABLE_NIMBUS"] "0" envFlags) != "0";

  #buildStatusGoDesktopLib = callPackage ./desktop {
  #  inherit utils;
  #};

  #hostConfigs = {
  #  darwin = {
  #    name = "macos";
  #    allTargets = [ status-go-packages.desktop status-go-packages.ios status-go-packages.android ];
  #  };
  #  linux = {
  #    name = "linux";
  #    allTargets = [ status-go-packages.desktop status-go-packages.android ];
  #  };
  #};
  #currentHostConfig = if stdenv.isDarwin then hostConfigs.darwin else hostConfigs.linux;

  #statusGoArgs = { inherit (source) src owner repo rev cleanVersion goPackagePath; inherit goBuildFlags goBuildLdFlags; };
  #status-go-packages = {
  #  desktop = buildStatusGoDesktopLib (statusGoArgs // {
  #    outputFileName = "libstatus.a";
  #    hostSystem = stdenv.hostPlatform.system;
  #    host = currentHostConfig.name;
  #  });

  #  android = buildStatusGoMobileLib (statusGoArgs // {
  #    host = mobileConfigs.android.name;
  #    targetConfig = mobileConfigs.android;
  #  });

  #  ios = buildStatusGoMobileLib (statusGoArgs // {
  #    host = mobileConfigs.ios.name;
  #    targetConfig = mobileConfigs.ios;
  #  });
  #};

  #android = rec {
  #  buildInputs = [ status-go-packages.android ];
  #  shell = mkShell {
  #    inherit buildInputs;
  #    shellHook = ''
  #      # These variables are used by the Status Android Gradle build script in android/build.gradle
  #      export STATUS_GO_ANDROID_LIBDIR=${status-go-packages.android}/lib
  #    '';
  #  };
  #};
  #ios = rec {
  #  buildInputs = [ status-go-packages.ios ];
  #  shell = mkShell {
  #    inherit buildInputs;
  #    shellHook = ''
  #      # These variables are used by the iOS build preparation section in nix/mobile/ios/default.nix
  #      export STATUS_GO_IOS_LIBDIR=${status-go-packages.ios}/lib/Statusgo.framework
  #    '';
  #  };
  #};
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
  mobile = callPackage ./mobile {
    inherit source goBuildFlags goBuildLdFlags;
  };

  #shell = mergeSh mkShell {} (catAttrs "shell" platforms);

  # CHILD DERIVATIONS
  #inherit android ios desktop;
}
