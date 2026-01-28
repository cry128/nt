{this, ...}: let
  inherit
    (builtins)
    isAttrs
    isFunction
    ;

  inherit
    (this.std)
    enfAllAttrs
    enfHasAttr
    ;

  inherit
    (this.std.maybe)
    nullableToMaybe
    ;

  enfNoNullTraps = decl: msg:
    enfAllAttrs (_: value: value != null) decl.unlock "decl.unlock" "be null" msg;
in rec {
  masterkey = "_''traps''_";
  defaultTrapdoorKey = "_'";
  mkTrapdoorKey = id: "${defaultTrapdoorKey}${id}";

  mkTrapdoorFn = decl:
    assert enfHasAttr "default" decl "mkTrapdoorFn";
    assert enfHasAttr "unlock" decl "mkTrapdoorFn";
    assert enfNoNullTraps decl "mkTrapdoorFn";
    # return trapdoor function
      (x:
        if x == masterkey
        then decl.unlock
        else decl.default x);

  mkTrapdoorSet = decl:
    assert enfHasAttr "default" decl "mkTrapdoorSet";
    assert enfHasAttr "unlock" decl "mkTrapdoorSet";
    assert enfNoNullTraps decl "mkTrapdoorFn";
    # return trapdoor set
      decl.default
      // {
        ${masterkey} = decl.unlock;
      };

  isTrapdoorFnKey = key: T: isFunction T && (T masterkey) ? ${key};

  isTrapdoorSetKey = key: T: T ? ${masterkey}.${key};

  isTrapdoorKey = key: T:
    if isAttrs T
    then isTrapdoorSetKey key T
    else isTrapdoorFnKey key T;

  openTrapdoor = key: T:
    nullableToMaybe (
      if isFunction T
      then (T masterkey).${key} or null
      else if isAttrs T
      then T.${masterkey}.${key} or null
      else null
    );
}
