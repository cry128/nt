{this, ...}: let
  inherit
    (builtins)
    attrNames
    elem
    isFunction
    ;

  inherit
    (this)
    enfHasAttr
    enfHasAttr'
    enfIsType
    ;
in rec {
  masterkey = "_''traps''_";
  defaultTrapdoorKey = "_'";
  mkTrapdoorKey = id: "${defaultTrapdoorKey}${id}";
  ntTrapdoorKey = mkTrapdoorKey "nt";

  mkTrapdoorFn = key: decl:
    assert enfHasAttr "default" decl "mkTrapdoorFn";
    assert enfHasAttr' "unlock" decl "mkTrapdoorFn";
    # return trapdoor function
      (x: let
        keys = attrNames decl.unlock;
      in
        if elem key keys
        then decl.unlock.${key}
        else if key == masterkey
        then keys
        else decl.default);

  mkTrapdoorSet = key: decl:
    assert enfHasAttr "default" decl "mkTrapdoorSet";
    assert enfHasAttr' "unlock" decl "mkTrapdoorSet";
    # return trapdoor set
      let
        keys = attrNames decl.unlock;
      in
        decl.default
        // {
          ${key} = decl.unlock.${key};
          ${masterkey} = keys;
        };
  revealTrapdoors = openTrapdoor masterkey;

  openTrapdoorFn = key: f: f key;

  openTrapdoorSet = key: xs: xs.${key};

  # TODO: implement a function called enfIsTypeAny (for cases like this where it might be function or set)
  openTrapdoor = key: T:
    if isFunction T
    then openTrapdoorFn key T
    else
      assert enfIsType "set" T "openTrapdoor";
        openTrapdoorSet key T;
}
