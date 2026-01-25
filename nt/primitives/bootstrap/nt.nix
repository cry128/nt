{this, ...}: let
  inherit
    (builtins)
    all
    attrNames
    elem
    isAttrs
    isString
    typeOf
    ;

  inherit
    (this)
    mkTrapdoorKey
    openTrapdoor
    ;
in rec {
  # check if a value is an nt type/class
  isNT = T: let
    content = openTrapdoor ntTrapdoorKey T;
    names = attrNames content;
  in
    isAttrs content
    && all (name: elem name names) ["sig" "derive" "ops" "req"];

  isNixClass = T: let
    content = openTrapdoor ntTrapdoorKey T;
  in
    isAttrs content
    && attrNames content == ["sig" "derive" "ops" "req"];

  isNixType = T: let
    content = openTrapdoor ntTrapdoorKey T;
  in
    isAttrs content
    && attrNames content == ["instance" "sig" "derive" "ops" "req"]
    && content.instance == false;

  isNixTypeInstance = T: let
    content = openTrapdoor ntTrapdoorKey T;
  in
    isAttrs content
    && attrNames content == ["instance" "sig" "derive" "ops" "req"]
    && content.instance == true;

  # check if a type/class implements a signature
  # NOTE: unsafe variant, use typeSig if you can't guarantee `isNT T` holds
  impls' = type: T: elem (toTypeSig type) T.${ntTrapdoorKey}.derive;

  # NOTE safe variant, use impls' if you can guarantee `isNT T` holds
  impls = type: T: assert enfIsNT T "nt.impls"; impls' type T;

  # check if a type/class implements a signature
  # NOTE: unsafe variant, use `is` if you can't guarantee `isNT T` holds
  is' = type: T: T.${ntTrapdoorKey}.sig == toTypeSig type;

  # NOTE safe variant, use `is'` if you can guarantee `isNT T` holds
  is = type: T: assert enfIsNT T "nt.is"; is' type T;

  # NOTE: unsafe variant, use typeSig if you can't guarantee `isNT T` holds
  typeSig' = T: T.${ntTrapdoorKey}.sig;

  # # NOTE: safe variant, use typeSig' if you can guarantee `isNT T` holds
  typeSig = T: assert enfIsNT T "nt.typeSig"; typeSig' T;

  toTypeSig = x:
    if isString x
    then x
    else typeSig x;

  # XXX: TODO: move ntTrapdoorKey to nt.nix
  ntTrapdoorKey = mkTrapdoorKey "nt";

  enfIsType = type: value: msg: let
    got = typeOf value;
  in
    got == type || throw "${msg}: expected primitive nix type \"${type}\" but got \"${got}\"";

  enfIsNT = T: msg:
    isNT T || throw "${msg}: expected nt compatible type but got \"${toString T}\" of primitive nix type \"${typeOf T}\"";

  enfImpls = type: T: msg:
    impls type T || throw "${msg}: given type \"${toTypeSig T}\" does not implement typeclass \"${toTypeSig type}\"";
}
