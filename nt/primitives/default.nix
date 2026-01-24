{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  includes.public = [
    ./nt.nix
  ];
  submods.public = [
    # TODO: make ./util private
    ./util
  ];
})
