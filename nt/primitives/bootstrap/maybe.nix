{...}: let
  inherit
    (builtins)
    attrNames
    concatStringsSep
    isAttrs
    typeOf
    ;
in rec {
  # NOTE: Maybe intentionally doesn't use the NixTypes.
  # NOTE: Maybe is used to aid in parsing and bootstrapping.
  # NOTE: It is intentionally left simple for speed gains.
  Maybe = some: value: {
    _some = some;
    _value = value;
  };
  Some = Maybe true;
  None = Maybe false null;

  # Type Checking
  isMaybe = T: isAttrs T && attrNames T == ["_some" "_value"];
  enfIsMaybe = T: msg: let
    throw' = got: throw "${msg}: expected naive type Maybe but got ${got}";
    attrs =
      attrNames T
      |> map (name: "\"${name}\"")
      |> concatStringsSep ", ";
  in
    if isAttrs T
    then isMaybe T || throw' "attribute set with structure [${attrs}]"
    else throw' "value \"${toString T}\" of primitive type \"${typeOf T}\"";

  isSome = T:
    assert enfIsMaybe T "isMaybeSome";
      T._some;

  isNone = T:
    assert enfIsMaybe T "isMaybeNone";
      ! T._some;

  # TODO: ensure you check isNone if isSome fails (otherwise it could be another type!)
  # Unwrap (Monadic Return Operation)
  # unwrapMaybe = f: g: T:
  #   if isSome T
  #   then f T._value_
  #   else g T._value_;
  # unwrapSome = unwrapMaybe (v: v);
  # unwrapNone = f: unwrapMaybe f (v: v);

  # Map (Monadic Bind Operation)
  mapMaybe = f: T:
    if isSome T
    then Some (f T._value)
    else T;

  # Conditionals
  # someOr = f: T:
  #   if isSome T
  #   then T
  #   else f T;

  # noneOr = f: T:
  #   if isNone T
  #   then T
  #   else f T;

  boolToMaybe = x:
    if x
    then Some true
    else None;

  nullableToMaybe = x:
    if x == null
    then None
    else Some x;

  maybeTobool = isSome;
}
