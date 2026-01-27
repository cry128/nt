{this, ...}: let
  inherit
    (builtins)
    foldl'
    isAttrs
    mapAttrs
    ;

  inherit
    (this.std)
    enfIsAttrs
    ;

  inherit
    (this.maybe)
    isSome
    mapSome
    unwrapMaybe
    Some
    None
    ;
in rec {
  # getAttrAt :: [String] -> Attrs -> Maybe a
  # Given an attribute set path as a list of strings,
  # returns the value of an attribute set at that path (Some)
  # if it exists, otherwise returns None.
  getAttrAt = path: xs:
    assert enfIsAttrs xs "getAttrAt";
      foldl' (acc: el:
        acc
        |> mapSome (x:
          if x ? ${el}
          then Some x.${el}
          else None))
      (Some xs)
      path;

  # hasAttrAt :: [String] -> Attrs -> Bool
  # Given an attribute set path as a list of strings,
  # returns a boolean indicating whether that path exists.
  hasAttrAt = path: xs:
    assert enfIsAttrs xs "hasAttrAt";
      getAttrAt path xs |> isSome; # NOTE: inefficient (im lazy)

  # recmapFrom :: [String] -> ([String] -> Attrs -> a) -> Attrs -> a | Attrs a
  # Alternative to mapAttrsRecursiveCond
  # Allows mapping directly from a child path
  recmapFrom = path: f: T:
    if isAttrs T
    then mapAttrs (attr: leaf: recmapFrom (path ++ [attr]) f leaf) T
    else f path T;

  # recmap :: ([String] -> Attrs -> a) -> Attrs -> a | Attrs a
  recmap = recmapFrom [];

  projectOnto = dst: src:
    dst
    |> recmap
    (path: dstLeaf: let
      srcLeaf = getAttrAt path src;
    in
      if isSome srcLeaf
      then unwrapMaybe srcLeaf
      else dstLeaf);
}
