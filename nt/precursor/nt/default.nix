{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  includes.public = [
    ./nt.nix
    ./sig.nix
    ./class.nix
  ];
  submods.public = [
    ./trapdoor.nix
  ];
})
