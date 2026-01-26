{
  flake,
  this,
  ...
}: let
  inherit
    (builtins)
    derivation
    getFlake
    ;

  inherit
    (this)
    genAttrs
    ;

  # TODO: rewrite nix-unit to lose dependency
  nix-unit-flake = getFlake "github.com:nix-community/nix-unit?rev=5e224c19c7087daebb7f7ac95acdfdcc08ea7433";

  forAllSystems = genAttrs [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];
in {
  tests.testPass = {
    expr = 3;
    expected = 4;
  };

  checks = forAllSystems (system: let
    nix-unit = "${nix-unit-flake.packages.${system}.default}/bin/nix-unit";
  in {
    default = derivation {
      inherit system;
      name = "nt-units";
      builder = "/bin/sh";

      args = [
        "-c"
        ''export HOME="$(realpath .)"; ${nix-unit} --eval-store "$HOME" --flake ${flake}#tests --extra-experimental-features flakes --extra-experimental-features nix-command --extra-experimental-features pipe-operators; touch $out''
      ];

      # XXX: TODO: is nix-unit-flake built in the sandbox (probably not right?)
      # fixed-output-derivation by using output* options
      # outputHashMode = "flat";
      # outputHashAlgo = "sha256";
      # outputHash = "";
    };
  });
}
