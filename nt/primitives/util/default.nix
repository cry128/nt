{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  includes.public = [
    ./nt.nix
    ./trapdoor.nix
  ];
})
