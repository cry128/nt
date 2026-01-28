{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  includes = {
    public = [
      ./nt.nix
    ];
    protected = [
      ./bootstrap
    ];
  };
})
