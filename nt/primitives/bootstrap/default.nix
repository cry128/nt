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

  # NOTE: bootstrap does the equivalent to mix's `include.public` option.
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
in
  bootstrap {} [
    ./nt.nix
    {
      bootstrap = _: bootstrap;
      std = ./std/bootstrap.nix;
      parse = ./parse/bootstrap.nix;

      maybe = ./maybe.nix;
      trapdoor = ./trapdoor.nix;
    }
  ]
