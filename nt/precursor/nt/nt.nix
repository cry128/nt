{this, ...}: let
  inherit
    (builtins)
    attrNames
    elem
    typeOf
    ;

  inherit
    (this)
    toTypeSig
    ;

  inherit
    (this.trapdoor)
    mkTrapdoorKey
    openTrapdoor
    ;

  inherit
    (this.prim)
    contains
    not
    ;

  inherit
    (this.naive.maybe)
    isSome
    bindMaybe
    ;
in rec {
  ntTrapdoorKey = mkTrapdoorKey "nt";
  ntDynamicTrapdoorKey = mkTrapdoorKey "ntDyn";

  openNT = openTrapdoor ntTrapdoorKey;

  # check if a value is NOT NixTypes compatible
  isPrimitive = not isNT;

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

  enfIsPrimitive = type: value: msg: let
    got = typeOf value;
  in
    got == type || throw "${msg}: expected primitive nix type \"${type}\" but got \"${got}\"";

  enfIsNT = T: msg:
    isNT T || throw "${msg}: expected nt compatible type but got \"${toString T}\" of primitive nix type \"${typeOf T}\"";

  enfImpls = type: T: msg:
    impls type T || throw "${msg}: given type \"${toTypeSig T}\" does not implement typeclass \"${toTypeSig type}\"";

  # XXX: TODO: Implement isomorphisms between types, especially
  # XXX: TODO: implicit isomorphisms from nix primitives to NT types.

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
}
