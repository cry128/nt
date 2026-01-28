{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  includes.public = [
    ./nt
  ];
  # XXX: TODO: submods.protected STILL doesn't work??
  submods.public = [
    ./std
  ];
})
