{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  isolated = true;
  includes.public = [
    ./nt
  ];
  submods.protected = [
    ./std
  ];
})
