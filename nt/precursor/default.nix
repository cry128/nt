{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  isolated = true;
  includes = {
    public = [
      ./nt
    ];
    protected = [
      # XXX: WARNING: reimplement std but typesafe
      ./bootstrap
    ];
  };
})
