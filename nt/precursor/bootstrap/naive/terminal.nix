{...}: let
  inherit
    (builtins)
    attrNames
    concatStringsSep
    isAttrs
    typeOf
    ;
in rec {
  # Naive Terminal Type
  # NOTE: preserves lazy eval for _value
  Terminal = value: {
    _value = value;
  };

  # Type Checking
  isTerminal = T: isAttrs T && attrNames T == ["_value"];
  # XXX: TODO: make a pretty toString function
  # XXX: TODO: make a pretty toString function
  # XXX: TODO: make a pretty toString function
  # XXX: TODO: make a pretty toString function
  enfIsTerminal = T: msg: let
    throw' = got: throw "${msg}: expected naive type Terminal but got ${got}";
    attrs =
      attrNames T
      |> map (name: "\"${name}\"")
      |> concatStringsSep ", ";
  in
    if isAttrs T
    then isTerminal T || throw' "attribute set with structure [${attrs}]"
    else throw' "value \"${toString T}\" of primitive type \"${typeOf T}\"";

  # Unwrap Operation
  # Lift a value out of the Terminal context.
  unwrapTerminal = T:
    assert enfIsTerminal T "unwrapTerminal";
      T._value;
}
