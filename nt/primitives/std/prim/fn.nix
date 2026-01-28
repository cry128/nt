{...}: let
  inherit
    (builtins)
    isFunction
    ;
in rec {
  id = x: x;

  # syntactic sugar for curry flipping
  flip = f: a: b: f b a;

  # syntactic sugar for recursive definitions
  recdef = def: let
    Self = def Self;
  in
    Self;

  # not sure where else to put this...
  nullOr = f: x:
    if x != null
    then f x
    else x;

  not = f:
    if isFunction f
    then x: not (f x)
    # WARNING: assume isBool holds (or fail)
    else ! f;
}
