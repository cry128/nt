{this, ...}: let
  inherit
    (builtins)
    attrNames
    elem
    getAttr
    isString
    typeOf
    ;

  inherit
    (this.std)
    contains
    ;

  inherit
    (this.maybe)
    isSome
    bindMaybe
    ;

  inherit
    (this.trapdoor)
    mkTrapdoorKey
    openTrapdoor
    ;
in rec {
  openNT = openTrapdoor ntTrapdoorKey;

  # check if a value is NixTypes compatible
  isNT = T:
    openNT T
    |> bindMaybe (content: attrNames content |> contains ["sig" "derive" "ops" "req"])
    |> isSome;

  isNTClass = T:
    openNT T
    |> bindMaybe (content: attrNames content == ["sig" "derive" "ops" "req"])
    |> isSome;

  isNTType = T:
    openNT T
    |> bindMaybe (content:
      attrNames content
      == ["instance" "sig" "derive" "ops" "req"]
      && content.instance == false)
    |> isSome;

  isNTInstance = T:
    openNT T
    |> bindMaybe (content:
      attrNames content
      == ["instance" "sig" "derive" "ops" "req"]
      && content.instance == true)
    |> isSome;

  # XXX: TODO: Implement isomorphisms between types especially
  # XXX: TODO: implicit isomorphism from nix primitives to NT types.

  impls = type: T:
    assert enfIsNT T "nt.impls";
      openNT T
      |> bindMaybe (content: content.derive |> elem (toTypeSig type))
      |> isSome;

  is = type: T:
    assert enfIsNT T "nt.is";
      openNT T
      |> bindMaybe (content: content.sig == toTypeSig type)
      |> isSome;

  typeSig = T:
    assert enfIsNT T "nt.typeSig";
      openNT T
      |> bindMaybe (getAttr "sig")
      |> isSome;

  toTypeSig = x:
    if isString x
    then x
    else typeSig x;

  ntTrapdoorKey = mkTrapdoorKey "nt";
  ntDynamicTrapdoorKey = mkTrapdoorKey "ntDyn";

  enfIsPrimitive = type: value: msg: let
    got = typeOf value;
  in
    got == type || throw "${msg}: expected primitive nix type \"${type}\" but got \"${got}\"";

  enfIsNT = T: msg:
    isNT T || throw "${msg}: expected nt compatible type but got \"${toString T}\" of primitive nix type \"${typeOf T}\"";

  enfImpls = type: T: msg:
    impls type T || throw "${msg}: given type \"${toTypeSig T}\" does not implement typeclass \"${toTypeSig type}\"";
}
