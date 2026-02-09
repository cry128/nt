{
  description = "NixTypes (nt)";

  inputs = {
    systems.url = "github:nix-systems/default";

    # NOTE: nixpkgs is only used in devshells
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # NOTE: nix-unit is only used in checks
    nix-unit = {
      url = "github:nix-community/nix-unit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-experimental-features = "pipe-operators";
  };

  outputs = {
    self,
    systems,
    nixpkgs,
    nix-unit,
  }: let
    inherit
      (mix)
      newMixture
      ;

    # inputs accessible to all modules
    inputs = {
      inherit mix;
      flake = self;
      # flake dependencies
      # NOTE: the NixTypes library has no dependencies
      # NOTE: but the developer tooling (for me) does
      # XXX: TODO: implement mix.extend instead of this
      deps = {
        inherit nixpkgs nix-unit;
        systems = import systems;
      };
    };

    bootstrap = import ./nt/precursor/bootstrap;
    mix = import ./nt/mix/bootstrap.nix {this = bootstrap;};
  in
    newMixture inputs (mixture: {
      includes.public = [
        ./flake
        ./nt
      ];
    });
}
