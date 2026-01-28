{
  this,
  mix,
  ...
}: let
  inputs = {
    nt = this;
    inherit mix;
  };
in
  mix.newMixture inputs (mixture: {
    includes = {
      public = [
        ./mixture.nix
      ];
      protected = [
        ./import.nix
      ];
    };
  })
