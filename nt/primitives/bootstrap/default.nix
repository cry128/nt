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
  bootstrap = inputs: let
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
    delegate;

  this = bootstrap {inherit this bootstrap;} [
    ./nt.nix
    {
      std = ./std/bootstrap.nix;
      parse = ./parse/bootstrap.nix;

      maybe = ./maybe.nix;
      trapdoor = ./trapdoor.nix;
    }
  ];
in
  this
