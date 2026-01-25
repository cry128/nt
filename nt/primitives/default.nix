{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  includes.public = [
    ./nt.nix
    ./bootstrap
  ];
  submods.public = [
    ./mix
    # TODO: make ./util private
    ./util
  ];
})
