{this, ...}: let
  inherit
    (builtins)
    attrNames
    elem
    elemAt
    filter
    hasAttr
    head
    length
    mapAttrs
    partition
    removeAttrs
    tail
    typeOf
    ;

  inherit
    (this)
    flipCurry
    id
    ;
in rec {
  enfIsAttrs = value: msg: let
    got = typeOf value;
  in
    got == "set" || throw "${msg}: expected primitive nix type \"set\" but got \"${got}\"";

  # NOTE: doesn't check if xs is type set, use enfHasAttr instead
  enfHasAttrUnsafe = name: xs: msg:
    hasAttr name xs || throw "${msg}: missing required attribute \"${name}\"";

  # NOTE: use enfHasAttr' if you can guarantee xs is type set
  enfHasAttr = name: xs: msg:
    enfIsAttrs xs msg && enfHasAttrUnsafe name xs msg;

  getAttrOr = name: f: xs:
    if xs ? ${name}
    then xs.${name}
    else f xs;

  getAttrDefault = name: default: getAttrOr name (_: default);

  mergeAttrsList = list: let
    # `binaryMerge start end` merges the elements at indices `index` of `list` such that `start <= index < end`
    # Type: Int -> Int -> Attrs
    binaryMerge = start: end:
    # assert start < end; # Invariant
      if end - start >= 2
      then
        # If there's at least 2 elements, split the range in two, recurse on each part and merge the result
        # The invariant is satisfied because each half will have at least 1 element
        binaryMerge start (start + (end - start) / 2) // binaryMerge (start + (end - start) / 2) end
      else
        # Otherwise there will be exactly 1 element due to the invariant, in which case we just return it directly
        elemAt list start;
  in
    if list == []
    then
      # Calling binaryMerge as below would not satisfy its invariant
      {}
    else binaryMerge 0 (length list);

  removeAttrsRec = paths: xs: let
    parts = partition (p: length p == 1) paths;
    here = parts.right;
    next = parts.wrong;
  in
    xs
    |> flipCurry removeAttrs here
    |> mapAttrs (name:
      if ! elem name next
      then id
      else
        next
        |> filter (x: head x == name)
        |> map tail
        |> removeAttrsRec);

  filterAttrs = pred: xs:
    attrNames xs
    |> filter (name: ! pred name xs.${name})
    |> removeAttrs xs;

  nameValuePair = name: value: {inherit name value;};
}
