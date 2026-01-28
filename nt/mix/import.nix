{this, ...}: let
  inherit
    (builtins)
    isAttrs
    isFunction
    listToAttrs
    typeOf
    ;

  inherit
    (this)
    enfIsPrimitive
    ;

  inherit
    (this.std)
    hasInfix
    mergeAttrsList
    nameValuePair
    removeSuffix
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
          Mix modules expect primitive type "set" or "lambda" (returning "set").
          Got primitive type "${typeOf mod}" instead.
        '';
        assert isAttrs modResult
        || throw ''
          Mix module provided as primitive type "lambda" must return primitive type "set"!
          Got primitive return type "${typeOf modResult} instead."
        ''; modResult;

  mkIncludes = list: inputs:
    list
    |> map (path: (importMod path inputs))
    |> mergeAttrsList;

  mkSubMods = list: inputs:
    list
    |> map (path: nameValuePair (modNameFromPath path) (importMod path inputs))
    |> listToAttrs;
}
