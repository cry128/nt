{...}: let
  inherit
    (builtins)
    attrNames
    concatStringsSep
    isAttrs
    typeOf
    ;
in rec {
  # Naive Require Type
  Require = pred: let
    got = typeOf pred;
  in
    assert (got == "lambda")
    || throw ''
      Naive type "Require" requires a predicate context of
      primitive type "lambda"! But got "${got}".
    ''; {
      _pred = pred;
    };

  # Type Checking
  isRequire = T: isAttrs T && attrNames T == ["_pred"];
  enfIsRequire = T: msg: let
    throw' = got: throw "${msg}: expected naive type Require but got ${got}";
    attrs =
      attrNames T
      |> map (name: "\"${name}\"")
      |> concatStringsSep ", ";
  in
    if isAttrs T
    then isRequire T || throw' "attribute set with structure [${attrs}]"
    else throw' "pred \"${toString T}\" of primitive type \"${typeOf T}\"";

  applyRequire = T: x: let
    result = T._pred x;
    got = typeOf result;
  in
    assert (got == "bool")
    || throw ''
      Naive type "Require" must return primitive type "bool"!
      But got "${got}".
    ''; result;
}
