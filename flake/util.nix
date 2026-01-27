{
  flake,
  deps,
  ...
}: let
  inherit
    (builtins)
    attrValues
    ;

  inherit
    (deps)
    systems
    nixpkgs
    ;
in {
  forAllSystems = f:
    nixpkgs.lib.genAttrs systems (system:
      f system (import nixpkgs {
        inherit system;
        allowUnfree = false;
        allowBroken = false;
        overlays = attrValues (
          if flake ? overlays
          then flake.overlays
          else {}
        );
      }));
}
