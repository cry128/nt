{
  flake,
  systems,
  nixpkgs,
  ...
}: let
  inherit
    (builtins)
    attrValues
    ;
in {
  forAllSystems = f:
    nixpkgs.lib.genAttrs systems (system:
      f system (import nixpkgs {
        inherit system;
        allowUnfree = false;
        allowBroken = false;
        overlays = attrValues flake.overlays;
      }));
}
