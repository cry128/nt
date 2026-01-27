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
    mapMaybe
    ;

  inherit
    (this.trapdoor)
    mkTrapdoorKey
    openTrapdoor
    ;
in rec {
  openNT = openTrapdoor ntTrapdoorKey;

  # check if a value is an nt type/class
  isNT = T:
    openNT T
    |> mapMaybe (content: attrNames content |> contains ["sig" "derive" "ops" "req"])
    |> isSome;

  isNTClass = T:
    openNT T
    |> mapMaybe (content: attrNames content == ["sig" "derive" "ops" "req"])
    |> isSome;

  isNTType = T:
    openNT T
    |> mapMaybe (content:
      attrNames content
      == ["instance" "sig" "derive" "ops" "req"]
      && content.instance == false)
    |> isSome;

  isNTInstance = T:
    openNT T
    |> mapMaybe (content:
      attrNames content
      == ["instance" "sig" "derive" "ops" "req"]
      && content.instance == true)
    |> isSome;

  # XXX: TODO: Some of these functions are unsafe but aren't marked as unsafe
  # XXX: TODO: because they WILL BE safe once I implement isomorphisms between types
  # XXX: TODO: especially implicit isomorphism from nix primitives to NT types

  impls = type: T:
    assert enfIsNT T "nt.impls";
      openNT T
      |> mapMaybe (content: content.derive |> elem (toTypeSig type))
      |> isSome;

  is = type: T:
    assert enfIsNT T "nt.is";
      openNT T
      |> mapMaybe (content: content.sig == toTypeSig type)
      |> isSome;

  typeSig = T:
    assert enfIsNT T "nt.typeSig";
      openNT T
      |> mapMaybe (getAttr "sig")
      |> isSome;

  toTypeSig = x:
    if isString x
    then x
    else typeSig x;

  # XXX: TODO: move ntTrapdoorKey to nt.nix
  ntTrapdoorKey = mkTrapdoorKey "nt";

  # TODO: rename enfIsType -> enfIsPrimitive
  enfIsType = type: value: msg: let
    got = typeOf value;
  in
    got == type || throw "${msg}: expected primitive nix type \"${type}\" but got \"${got}\"";

  enfIsNT = T: msg:
    isNT T || throw "${msg}: expected nt compatible type but got \"${toString T}\" of primitive nix type \"${typeOf T}\"";

  enfImpls = type: T: msg:
    impls type T || throw "${msg}: given type \"${toTypeSig T}\" does not implement typeclass \"${toTypeSig type}\"";
}
