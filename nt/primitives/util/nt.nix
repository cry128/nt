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
    openTrapdoorFn
    toTypeSig
    ;
in rec {
  # check if a value is an nt type/class
  isNT = T: let
    content = openTrapdoorFn ntTrapdoorKey T;
    names = attrNames content;
  in
    isAttrs content
    && all (name: elem name names) ["sig" "derive" "ops" "req"];

  isNixClass = T: let
    content = openTrapdoorFn ntTrapdoorKey T;
  in
    isAttrs content
    && attrNames content == ["sig" "derive" "ops" "req"];

  isNixType = T: let
    content = openTrapdoorFn ntTrapdoorKey T;
  in
    isAttrs content
    && attrNames content == ["instance" "sig" "derive" "ops" "req"]
    && content.instance == false;

  isNixTypeInstance = T: let
    content = openTrapdoorFn ntTrapdoorKey T;
  in
    isAttrs content
    && attrNames content == ["instance" "sig" "derive" "ops" "req"]
    && content.instance == true;

  # check if a type/class implements a signature
  # NOTE: unsafe variant, use typeSig if you can't guarantee `isNT T` holds
  impls' = type: T: elem (toTypeSig type) T.${ntTrapdoorKey}.derive;

  # NOTE safe variant, use impls' if you can guarantee `isNT T` holds
  impls = type: T: assert enfIsNT "nt.impls" T; impls' type T;

  # check if a type/class implements a signature
  # NOTE: unsafe variant, use `is` if you can't guarantee `isNT T` holds
  is' = type: T: T.${ntTrapdoorKey}.sig == toTypeSig type;

  # NOTE safe variant, use `is'` if you can guarantee `isNT T` holds
  is = type: T: assert enfIsNT "nt.is" T; is' type T;
}
