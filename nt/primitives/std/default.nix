# WARNING: /nt/primitives/bootstrap cannot depend on mix!
# WARNING: This file is strictly for bootstrapping nt.
# WARNING: Use it with `import ./nt/primitives/bootstrap`
let
  inherit
    (builtins)
    foldl'
    isAttrs
    isList
    isPath
    mapAttrs
    ;

  # NOTE: bootstrap can do the equivalent of mix's
  # NOTE: `include.public` & `submods.public` options.
  bootstrap = extraInputs: target: let
    this = delegate target;
    inputs = {inherit this;} // extraInputs;

    delegate = target:
    # PATH
      if isPath target
      then import target inputs
      # LIST
      else if isList target
      then target |> foldl' (acc: el: acc // delegate el) {}
      # ATTRS
      else if isAttrs target
      then target |> mapAttrs (_: value: delegate value)
      # FUNCTION (OR FAIL)
      else target inputs;
  in
    this;

  submods = {
    bootstrap = _: bootstrap;
    # XXX: TODO: should I rename bootstrap.nix -> default.nix?
    prim = ./prim/bootstrap.nix;
    naive = ./naive/bootstrap.nix;
  };
in
  bootstrap {} [
    submods.prim
    submods.naive
    ./attrs.nix

    submods
  ]
