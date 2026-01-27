{
  this,
  flake,
  deps,
  ...
}: let
  inherit
    (builtins)
    concatStringsSep
    ;

  inherit
    (this.util)
    forAllSystems
    ;

  inherit
    (deps)
    nixpkgs
    nix-unit
    ;
in let
  enable-experimental = concatStringsSep " " [
    "flakes"
    "nix-command"
    "pipe-operators"
  ];
in {
  # XXX: TODO: assert false || throw "TEST: type of flake is \"${builtins.typeOf flake}\""
  checks = forAllSystems (
    system: pkgs: {
      default =
        pkgs.runCommand "tests"
        {
          nativeBuildInputs = [nix-unit.packages.${system}.default];
        }
        ''
          export HOME="$(realpath .)"
          # The nix derivation must be able to find all used inputs in the nix-store because it cannot download it during buildTime.
          nix-unit --eval-store "$HOME"                            \
            --extra-experimental-features "${enable-experimental}" \
            --override-input nixpkgs ${nixpkgs}                    \
            --flake ${flake}\#tests
          touch $out
        '';
    }
  );
}
