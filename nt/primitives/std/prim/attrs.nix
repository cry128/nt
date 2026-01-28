{this, ...}: let
  inherit
    (builtins)
    all
    attrNames
    elem
    elemAt
    filter
    hasAttr
    head
    length
    listToAttrs
    mapAttrs
    partition
    removeAttrs
    tail
    typeOf
    ;

  inherit
    (this)
    flip
    id
    ;
in rec {
  enfIsAttrs = value: msg: let
    got = typeOf value;
  in
    got == "set" || throw "${msg}: expected primitive nix type \"set\" but got \"${got}\"";

  enfHasAttr = name: xs: msg:
    assert enfIsAttrs xs msg;
      hasAttr name xs || throw "${msg}: missing required attribute \"${name}\"";

  getAttrOr = name: f: xs: xs.${name} or f xs;
  getAttrDefault = name: default: xs: xs.${name} or default;

  genAttrs = names: f:
    names
    |> map (n: nameValuePair n (f n))
    |> listToAttrs;

  attrsToList = xs: mapAttrs nameValuePair xs;

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
    |> flip removeAttrs here
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

  # allAttrs :: (String -> Any -> Bool) -> AttrSet -> Bool
  allAttrs = pred: xs:
    attrNames xs |> all (name: pred name xs.${name});

  enfAllAttrs = pred: xs: xsName: reason: msg: let
    err = name: throw "${msg}: attribute \"${xsName}.${name}\" cannot ${reason}";
  in
    attrNames xs
    |> all (name: pred name xs.${name} || err name);

  # XXX: TODO: for every enf* function make an equivalent assert function
  # XXX: TODO: (these MUST be chainable for the pipe operator)
  assertAllAttrs = pred: xsName: reason: msg: xs:
    assert enfAllAttrs pred xs xsName reason msg; xs;
}
