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

  inherit
    (this.terminal)
    isTerminal
    unwrapTerminal
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
  recmapCondFrom = path: cond: f: T: let
    delegate = path': recmapCondFrom path' cond f;
  in
    if isAttrs T && cond path T
    then T |> mapAttrs (attr: leaf: delegate (path ++ [attr]) leaf)
    else f path T;

  # recmap :: ([String] -> Attrs -> a) -> Attrs -> a | Attrs a
  recmapCond = recmapCondFrom [];

  recmapZipOntoCondFrom = path: cond: f: dst: src: let
    zip = f': path': dstLeaf: f' path' dstLeaf (getAttrAt path' src);
  in
    dst
    |> recmapCondFrom path (zip cond) (zip f);

  recmapZipOntoCond = recmapZipOntoCondFrom [];

  projectOnto = dst: src:
    src
    |> recmapZipOntoCond
    (path: dstLeaf: srcLeaf: ! isTerminal dstLeaf)
    (path: dstLeaf: srcLeaf:
      if isSome srcLeaf
      then unwrapMaybe srcLeaf
      else if isTerminal dstLeaf
      then unwrapTerminal dstLeaf
      else dstLeaf)
    dst;
}
