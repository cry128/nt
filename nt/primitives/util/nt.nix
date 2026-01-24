{this, ...}: let
  inherit
    (builtins)
    all
    attrNames
    elem
    isAttrs
    ;

  inherit
    (this)
    enfIsNT
    ntTrapdoorKey
    openTrapdoor
    toTypeSig
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
}
