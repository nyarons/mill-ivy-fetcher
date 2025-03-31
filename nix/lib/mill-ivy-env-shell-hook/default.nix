/**
  mill-ivy-env-shell-hook call all the setupHook and do extra post

  # Type

  ```
  mill-ivy-env-shell-hook :: string
  ```

  # Examples
  :::{.example}
  ## `mill-ivy-env-shell-hook` usage example

  ```nix
  { stdenv, mill-ivy-env-shell-hook }:
  stdenv.mkDerivation {
    name = "my-mill-project";

    shellHook = ''
      ${mill-ivy-env-shell-hook}

      # extra commands
      mill -i mill.bsp.BSP/install
    '';
  }
  ```

  Then:

  ```bash
  $ nix develop '.#my-mill-project'
  ```

  :::
*/
{ }: ''
  if [[ ! -d ".git" || ! -f "build.mill" ]]; then
    echo "Not in mill project root, exit" >&2
    exit 1
  fi

  mkdir -p out
  NIX_BUILD_TOP="$(realpath out)"

  runHook preUnpack
  runHook postUnpack
''