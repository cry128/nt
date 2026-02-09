{nt, ...}: let
  inherit
    (builtins)
    foldl'
    isAttrs
    isFunction
    isList
    isPath
    mapAttrs
    typeOf
    ;

  inherit
    (nt)
    enfIsPrimitive
    hasInfix
    removeSuffix
    ;

  inherit
    (nt.naive.terminal)
    isTerminal
    unwrapTerminal
    ;

  modNameFromPath = path: let
    name = baseNameOf path |> removeSuffix ".nix";
  in
    assert (! hasInfix "." name)
    || throw ''
      Mix module ${path} has invalid name \"${name}\".
      Module names must not contain the . (period) character.
    ''; name;
in rec {
  # by default the imported module is given the basename of its path
  # but you can set it manually by using the `mix.mod` function.

  importMod = path: inputs:
    assert enfIsPrimitive "path" path "importMod"; let
      mod = import path;
    in
      if isAttrs mod
      then mod
      else let
        modResult = mod inputs;
      in
        # TODO: create a better version of toString that can handle sets, lists, and null
        assert isFunction mod
        || throw ''
          Imported Mix modules must be provided as primitive types "set" or "lambda" (returning "set").
          Got primitive type "${typeOf mod}" instead.
        '';
        assert isAttrs modResult
        || throw ''
          Imported Mix module provided as primitive type "lambda" must return primitive type "set"!
          Got primitive return type "${typeOf modResult} instead."
        ''; modResult;

  mkMod = pathDelegate: target: extraInputs: let
    this = delegate target;
    inputs = {inherit this;} // extraInputs;

    delegate = target:
    # PATH
      if isPath target
      then pathDelegate target inputs
      # LIST
      else if isList target
      then target |> foldl' (acc: el: acc // delegate el) {}
      # TERMINAL
      else if isTerminal target
      then unwrapTerminal target
      # ATTRS
      else if isAttrs target
      then target
      # FUNCTION (OR FAIL)
      else
        assert isFunction target
        || throw ''
          Mix module provided as invalid primitive type "${typeOf target}".
        '';
          target inputs;
  in
    this;

  mkIncludes = target: inputs: mkMod importMod target inputs;
  mkSubMods = target: inputs:
    mkMod (path: inputs': {
      ${modNameFromPath path} = importMod path inputs';
    })
    target
    inputs;
}
