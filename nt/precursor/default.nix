{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  isolated = true;
  includes = {
    public = [
      ./nt
      # XXX: DEBUG: make this protected
      ./bootstrap
    ];
    protected = [
      # XXX: WARNING: reimplement std but typesafe
      # ./bootstrap
    ];
  };
})
