# XXX: TODO: replace Null with the naive Maybe type
{this, ...}: let
  inherit
    (this)
    ntTrapdoorKey
    ;
  inherit
    (this.trapdoor)
    mkTrapdoorSet
    ;
in {
  # NOTE: This is not good for writing type safe code
  # NOTE: it is however efficient for bootstrapping the primitives
  Null =
    # WARNING: Null skips implementing a Type altogether
    # WARNING: Null is an orphaned Type instance
    mkTrapdoorSet ntTrapdoorKey {
      default = {};
      unlock = {
        instance = true;
        sig = "nt::Null";
        derive = [];
        ops = {};
        req = {};
      };
    };
}
