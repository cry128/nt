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

  outputs = {
    self,
    systems,
    nixpkgs,
    nix-unit,
  }: let
    # TODO: implement mix.extend and mix.isolate
    inherit
      (mix)
      extend
      # isolate
      newMixture
      ;

    # inputs accessible to all modules
    base = {
      inherit mix;
      flake = self;
      # XXX: TODO: implement mix.extend instead of this
      deps = {
        inherit nixpkgs nix-unit;
        systems = import systems;
      };
    };

    # flake dependencies
    # NOTE: the NixTypes library has no dependencies
    # NOTE: but the developer tooling (for me) does
    deps = {
      inherit systems nixpkgs nix-unit;
    };

    # Step 1: Bootstrap and blast off (*zooommmmm whoooosshhhhh pppppeeeeeeewww*)
    bootstrap = import ./nt/primitives/bootstrap;
    # Step 2: Lie to Mix about its real identity (it's not ready for the truth...)
    mix = import ./nt/mix {this = bootstrap;};
  in
    newMixture base (mixture: {
      includes.public = [
        # XXX: TODO: implement mix.extend
        # (extend ./flake deps)
        ./flake
        # Step 3: Actually import NixTypes
        ./nt
      ];
    });
  # Step 4: Like and subscripe!!1!11!!!!!
}
