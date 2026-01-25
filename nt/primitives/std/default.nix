# {mix, ...} @ inputs:
# mix.newMixture inputs (mixture: {
#   includes.public = [
#     ./attrs.nix
#     ./fn.nix
#     ./list.nix
#     ./num.nix
#     ./string.nix
#   ];
# })
# WARNING: /nt/primitives/std cannot depend on mix
# WARNING: this file is strictly for bootstrapping nt
let
  # input = {inherit this;};
  this = {
  };
  # this =
  #   import ./util.nix input
  #   // import ./parse.nix input
  #   // import ./trapdoor.nix input
  #   // import ./null.nix input
  #   // import ./maybe.nix input
  #   // import ./wrap.nix input
  #   // import ./enforce.nix input
  #   // import ./sig.nix input
  #   // import ./nt.nix input;
in
  this
