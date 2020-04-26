# This file defines custom shells as well as shortcuts
# for accessing more nested shells.
{
  config ? {},
  pkgs ? import ./pkgs.nix { inherit config; }
}:

let
  # everything else we define in nix/ dir
  targets = pkgs.callPackage ./targets.nix { inherit config; };

  # for calling lein targets in CI or Makefile
  leiningen-sh = pkgs.mkShell {
    buildInputs = with pkgs; [ clojure leiningen flock maven nodejs openjdk ];
  };

  # for 'make watchman-clean'
  watchman-sh = pkgs.mkShell {
    buildInputs = [ pkgs.watchman ];
  };

  # for running fastlane commands alone
  fastlane-sh = targets.mobile.fastlane.shell;

  # for 'scripts/generate-keystore.sh'
  keytool-sh = pkgs.mkShell {
    buildInputs = [ pkgs.openjdk8 ];
  };

  # the default shell that is used when target is not specified
  default = pkgs.mkShell {
    name = "status-react-shell"; # for identifying all shells
    buildInputs = with pkgs; lib.unique ([
      # core utilities that should always be present in a shell
      bash curl wget file unzip flock git gnumake jq ncurses
      # build specific utilities
      clojure leiningen maven watchman
      # other nice to have stuff
      yarn nodejs python27
    ] # and some special cases
      ++ lib.optionals stdenv.isDarwin [ cocoapods clang ]
      ++ lib.optionals (!stdenv.isDarwin) [ gcc8 ]
    );

    # avoid terinal issues
    TERM="xterm";

    # default locale
    LANG="en_US.UTF-8";
    LANGUAGE="en_US.UTF-8";

    # just a nicety for easy access to node scripts
    shellHook = ''
      export STATUS_REACT_HOME=$(git rev-parse --show-toplevel)
      export PATH="$STATUS_REACT_HOME/node_modules/.bin:$PATH"
    '';
  };

# values here can be selected using `nix-shell --argstr target $TARGET`
# the nix/scripts/shell.sh wrapper does this for us and expects TARGET to be set
in with pkgs; rec {
  inherit default;
  lein = leiningen-sh;
  watchman = watchman-sh;
  fastlane = fastlane-sh;
  keytool = keytool-sh;
  android-env = targets.mobile.android.env.shell;
  # helpers for use with target argument
  linux = targets.desktop.linux.shell;
  macos = targets.desktop.macos.shell;
  windows = targets.desktop.windows.shell;
  android = targets.mobile.android.shell;
  ios = targets.mobile.ios.shell;
  # all shells together depending on host OS
  all = lib.mergeSh (mkShell {}) (lib.unique (
    lib.optionals stdenv.isLinux  [ android linux windows ] ++
    lib.optionals stdenv.isDarwin [ android macos ios ]
  ));
}
