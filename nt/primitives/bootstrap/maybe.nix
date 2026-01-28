{...}: let
  inherit
    (builtins)
    attrNames
    concatStringsSep
    isAttrs
    typeOf
    ;
in rec {
  # Naive Maybe Type
  Maybe = some: value: {
    _some = some;
    _value = value;
  };
  Some = Maybe true;
  None = Maybe false null;

  # Type Checking
  isMaybe = T: isAttrs T && attrNames T == ["_some" "_value"];
  # XXX: TODO: make a pretty toString function
  # XXX: TODO: make a pretty toString function
  # XXX: TODO: make a pretty toString function
  # XXX: TODO: make a pretty toString function
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
    assert enfIsMaybe T "isSome";
      T._some;

  isNone = T:
    assert enfIsMaybe T "isNone";
      ! T._some;

  # Monadic Bind Operation
  bindMaybe = f: T:
    if isSome T
    then Some (f T._value)
    else T;

  # Unwrap Operations
  # Lift a value out of the monadic context.
  unwrapMaybe = T:
    assert enfIsMaybe T "unwrapMaybe";
      T._value;

  # Map Operations
  # Lift a value out of the monadic context and expect a new monadic.
  mapMaybe = f: g: T: let
    value =
      if isSome T
      then f T._value
      else g T._value;
  in
    assert enfIsMaybe value "mapMaybe"; value;

  mapSome = f: mapMaybe f (_: None);
  mapNone = mapMaybe (x: Some x);

  # Utility Functions
  boolToMaybe = x:
    if x
    then Some true
    else None;

  nullableToMaybe = x:
    if x == null
    then None
    else Some x;
}
