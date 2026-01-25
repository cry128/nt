{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  includes.public = [
    ./nt.nix
    ./bootstrap
  ];
  submods.public = [
    # TODO: make ./util private
    ./util
  ];
})
