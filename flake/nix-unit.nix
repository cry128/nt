{
  this,
  flake,
  deps,
  ...
}: let
  inherit
    (deps)
    nixpkgs
    nix-unit
    ;

  inherit
    (this.util)
    forAllSystems
    ;
in {
  checks = forAllSystems (system: {
    default =
      nixpkgs.legacyPackages.${system}.runCommand "tests"
      {
        nativeBuildInputs = [nix-unit.packages.${system}.default];
      }
      ''
        export HOME="$(realpath .)"
        # The nix derivation must be able to find all used inputs in the nix-store because it cannot download it during buildTime.
        nix-unit --eval-store "$HOME" \
          --extra-experimental-features flakes \
          --override-input nixpkgs ${nixpkgs} \
          --flake ${flake}#tests
        touch $out
      '';
  });
}
