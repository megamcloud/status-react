{ callPackage,
  source, goBuildFlags, goBuildLdFlags }:

{
  android = callPackage ./android { inherit source goBuildFlags goBuildLdFlags; };
  ios = callPackage ./ios { inherit source goBuildFlags goBuildLdFlags; };
}
