{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  isolated = true;
  includes.public = [
    ./precursor

    # (mix.isolate mix)
  ];
  submods.public = [
    ./mix
  ];
})
