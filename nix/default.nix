{ pkgs, lib, ... }: let
  dir = dirName: builtins.readDir ./${dirName}
    |> lib.filterAttrs (_: value: value == "directory")
    |> lib.concatMapAttrs (name: _: { ${name} = ./${dirName}/${name}; });
  scope = lib.makeScope pkgs.newScope
    (self: lib.mapAttrs (_: value: self.callPackage value {}) (dir "lib" // dir "packages"));
in {
  packages = { inherit (scope)
    add-determinism-hook
    configure-mill-env-hook
    mill-ivy-fetcher; };

  lib = { inherit (scope)
    ivy-gather
    mill-ivy-env-shell-hook
    publish-mill-jar; };
}
