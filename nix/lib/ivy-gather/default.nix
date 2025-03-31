/**
  Each Ivy dependencies will contains one or more files: the publish JAR file
  and the POM specification file. All those files are download separately to
  make nix-prefetch-file happy. This function can help group files to Ivy
  recognizable dependencies layout by reading the generated nix lock file.
  Returning a derivation containing the ivy cache.


  # Inputs

  `nvfetcherNixSourcePath`
  : 1\. Function argument

  # Type

  ```
  ivy-gather :: path -> set
  ```

  # Examples
  :::{.example}
  ## `ivy-gather` usage example

  ```nix
  ivy-gather ./codegenFiles/project-ivys.nix
  => <derivation>
  ```

  :::
*/

{ lib
, stdenvNoCC
, lndir
, fetchurl
, configure-mill-env-hook
}:

nixLock:

let
  sources = (import nixLock) { inherit fetchurl; };
in
stdenvNoCC.mkDerivation {
  name = "build-ivy-cache-env";
  dontUnpack = true;

  propagatedBuildInputs = [ lndir configure-mill-env-hook ];

  buildPhase = "runHook preBuild\n"
    + lib.concatMapStringsSep "\n"
    (x: ''
      mkdir -p "$out/cache/${x.installPath}"
      lndir ${x} "$out"/cache/${x.installPath}
    '')
    (lib.attrValues sources)
    + "\nrunHook postBuild";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"/nix-support
    substitute ${./ivy-gather-setup-hook.sh} "$out"/nix-support/setup-hook \
      --replace-fail "@cacheDir@" "$out/cache" \

    runHook postInstall
  '';

  passthru = { inherit sources; };
}
