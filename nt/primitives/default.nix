{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  includes.public = [
    ./nt
  ];
  submods.protected = [
    ./std
  ];
})
