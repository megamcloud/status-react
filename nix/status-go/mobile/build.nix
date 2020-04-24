{ lib, stdenv, utils, callPackage, buildGoPackage, go, gomobile, androidPkgs, openjdk
, unzip, zip, xcodeWrapper,
# custom arguments
owner, repo, shortRev, rev, cleanVersion, goPackagePath, src
# mobile-only arguments
, nimbusWrapper ? null
, platform ? "android"
, arch ? "arm64"
, goBuildFlags ? [ ]
, goBuildLdFlags ? [ ] }:

let
  inherit (lib)
    concatStrings concatStringsSep concatMapStrings
    substring optionalString mapAttrsToList
    makeBinPath optional optionals;

  removeReferences = [ go ];
  removeExpr = refs: ''remove-references-to ${concatMapStrings (ref: " -t ${ref}") refs}'';

  outputFileName = "status-go-${shortRev}-${arch}.aar";
  nimbusBridgeVendorDir =
    "$NIX_BUILD_TOP/go/src/${goPackagePath}/vendor/${goPackagePath}/eth-node/bridge/nimbus";
in buildGoPackage {
  pname = repo;
  version = "${cleanVersion}-${substring 0 7 rev}";

  meta = {
    description = "The Status module that consumes go-ethereum.";
    license = lib.licenses.mpl20;
    platforms = with lib.platforms; linux ++ darwin;
  };

  inherit goPackagePath src;

  nativeBuildInputs = [ gomobile unzip zip ]
    ++ optional (platform == "android") openjdk
    ++ optional stdenv.isDarwin xcodeWrapper;

  # Fixes Cgo related build failures (see https://github.com/NixOS/nixpkgs/issues/25959 )
  hardeningDisable = [ "fortify" ];

  # Ensure XCode is present, instead of failing at the end of the build
  preConfigure = optionalString stdenv.isDarwin utils.enforceXCodeAvailable;

  # OPTIONAL: Copy the Nimbus API artifacts to the expected vendor location
  nimbusPrep = optionalString (nimbusWrapper != null) (''
    cp ${nimbusWrapper}/{include/*,lib/libnimbus.a} ${nimbusBridgeVendorDir}
    chmod +w ${nimbusBridgeVendorDir}/libnimbus.{a,h}
  '');

  # Build mobile libraries
  preBuild =
    let
      NIX_GOWORKDIR = "$NIX_BUILD_TOP/go-build";
    in ''
      runHook nimbusPrep

      mkdir ${NIX_GOWORKDIR}

      export GO111MODULE=off
      export GOPATH=${gomobile.dev}:$GOPATH
      export PATH=${makeBinPath [ gomobile.bin ]}:$PATH
      export NIX_GOWORKDIR=${NIX_GOWORKDIR}

    '' + optionalString (platform == "android") ''
      export ANDROID_HOME=${androidPkgs}
      export ANDROID_NDK_HOME=${androidPkgs}/ndk-bundle
      export PATH="${makeBinPath [ openjdk ]}:$PATH"
    '';

  # Build the Go library using gomobile for each of the configured platforms
  buildPhase = let
    ldFlags = [ "-extldflags=-Wl,--allow-multiple-definition" ] ++ goBuildLdFlags;
    CGO_LDFLAGS = concatStringsSep " " ldFlags;
  in ''
    runHook preBuild
    runHook renameImports

    echo -e "\nBuilding for target ${platform}/${arch}\n"

    gomobile bind \
      -target=${platform}/${arch} \
      -ldflags="${CGO_LDFLAGS}" \
      ${optionalString (platform == "android") "-androidapi 23"} \
      ${optionalString (platform == "ios") "-iosversion=8.0"} \
      ${concatStringsSep " " goBuildFlags} \
      -o ${outputFileName} \
      ${goPackagePath}/mobile

    ls -l ${outputFileName}

    rm -rf $NIX_GOWORKDIR

    runHook postBuild
  '';

  postBuild = optionalString (nimbusWrapper != null) ''
    rm ${nimbusBridgeVendorDir}/libnimbus.{a,h}
  '';

  # replace hardcoded paths to go package in /nix/store, otherwise Nix will fail the build
  fixupPhase = ''
    find $out -type f -exec ${removeExpr removeReferences} '{}' + || true
  '';

  installPhase = ''
    mkdir -p $out/lib
    mv ${outputFileName} $out/lib/
  '';

  outputs = [ "out" ];
}
