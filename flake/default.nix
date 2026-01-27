{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  includes.public = [
    ./devshells.nix
    ./nix-unit.nix
  ];
  # TODO: make .util.nix private
  submods.public = [
    ./util.nix
    ../tests
  ];
})
