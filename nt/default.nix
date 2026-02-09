{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  includes.public = [
    ./precursor
  ];
  submods.public = [
    ./mix
  ];
})
