# XXX: TODO: use the custom Null type instance instead of the Wrap type
{this, ...}: let
  inherit
    (builtins)
    foldl'
    hasAttr
    isAttrs
    ;

  inherit
    (this)
    is
    ;

  inherit
    (this.std)
    enfIsAttrs
    ;
in rec {
  # form: getAttrAt :: list string -> set -> null | Wrap Any
  # given path as a list of strings, return that value of an
  # attribute set at that path
  getAttrAt = path: xs:
    assert enfIsAttrs xs "getAttrAt";
      foldl' (left: right:
        if left != null && isAttrs left.value && hasAttr right left.value
        then Wrap left.value.${right}
        else null)
      (Wrap xs)
      path;

  # form: hasAttrAt :: list string -> set -> bool
  # given path as a list of strings, return that value of an
  # attribute set at that path
  hasAttrAt = path: xs:
    assert enfIsAttrs xs "hasAttrAt";
      getAttrAt path xs != null; # NOTE: inefficient (im lazy)

  # Alternative to mapAttrsRecursiveCond
  # Allows mapping directly from a child path
  recmap = let
    recmapFrom = path: f: T:
      if builtins.isAttrs T && ! is Wrap T
      then builtins.mapAttrs (attr: leaf: recmapFrom (path ++ [attr]) f leaf) T
      else f path T;
  in
    recmapFrom [];

  projectOnto = dst: src:
    dst
    |> recmap
    (path: dstLeaf: let
      srcLeaf = getAttrAt path src;
      newLeaf =
        if srcLeaf != null
        then srcLeaf
        else dstLeaf;
    in
      if is Wrap newLeaf
      then newLeaf.value
      else newLeaf);
}
