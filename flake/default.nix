{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  includes.public = [
    ./devshells.nix
    ./nix-unit.nix
  ];
  submods.private = [
    ./util.nix
  ];
})
