{this, ...}: let
  inherit
    (builtins)
    isAttrs
    isFunction
    ;

  inherit
    (this.std)
    enfHasAttr
    enfHasAttrUnsafe
    ;

  inherit
    (this.types)
    Some
    None
    ;
in rec {
  masterkey = "_''traps''_";
  defaultTrapdoorKey = "_'";
  mkTrapdoorKey = id: "${defaultTrapdoorKey}${id}";

  mkTrapdoorFn = key: decl:
    assert enfHasAttr "default" decl "mkTrapdoorFn";
    assert enfHasAttrUnsafe "unlock" decl "mkTrapdoorFn";
    # return trapdoor function
      (x:
        if key == masterkey
        then decl.unlock
        else decl.default x);

  mkTrapdoorSet = key: decl:
    assert enfHasAttr "default" decl "mkTrapdoorSet";
    assert enfHasAttrUnsafe "unlock" decl "mkTrapdoorSet";
    # return trapdoor set
      decl.default
      // {
        ${masterkey} = decl.unlock;
      };

  isTrapdoorFnKey = key: T: isFunction T && (T masterkey) ? ${key};

  isTrapdoorSetKey = key: T:
    if T ? ${masterkey}
    then T.${masterkey} ? ${key}
    else false;

  isTrapdoorKey = key: T:
    if isAttrs T
    then isTrapdoorSetKey key T
    else isTrapdoorFnKey key T;

  openTrapdoorFn = key: T: let
    unlock = T masterkey;
  in
    if isFunction T && unlock ? ${key}
    then Some unlock.${key}
    else None;

  openTrapdoorSet = key: T: let
    unlock = T.${masterkey};
  in
    if T ? ${masterkey} && unlock ? ${key}
    then Some unlock.${key}
    else None;

  openTrapdoor = key: T:
    if isFunction T
    then openTrapdoorFn key T
    else if isAttrs T
    then openTrapdoorSet key T
    else None;
}
