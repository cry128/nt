{this, ...}: let
  inherit
    (builtins)
    all
    attrValues
    concatLists
    filter
    isFunction
    length
    mergeAttrsList
    partition
    typeOf
    ;

  inherit
    (this)
    enfIsType
    enfIsClassSig
    isClass
    enfIsTypeSig
    ntTrapdoorKey
    typeSig
    ;

  inherit
    (this.trapdoor)
    mkTrapdoorSet
    ;

  inherit
    (this.prim)
    flip
    hasAttrAt
    projectOnto
    recdef
    removeAttrsRec
    unique
    ;

  inherit
    (this.naive.terminal)
    Terminal
    ;

  inherit
    (this.naive.require)
    isRequire
    ;

  classDecl = {
    derive = Terminal [];
    ops = Terminal {};
  };

  # XXX: i think this works?
  typeDecl = classDecl;

  unwrapBuilder = builder: Self:
    if isFunction builder
    then builder Self
    else builder;

  parseDecl = base: decl:
    assert enfIsType "set" decl "parseDecl";
    # ^^^^ "Type declaration must be provided as an attribute set, got "${typeOf decl}" instead!"
      decl |> projectOnto base;

  # Algorithm: given a full set of ops, iterate each op and
  # IF IT MATCHES A DERIVE BY FULL NAMESPACE
  # THEN remove it from state.req
  # ELSE IF IT IS SPECIFIED BY NAMESPACE
  # THEN add it to a list of all invalid ops (errors)
  # ELSE add it to a list of ops belonging solely to self
  parseOps = decl: let
    opsFormatted = assert (
      decl.ops
      |> attrValues
      |> all isFunction
    )
    || throw ''
      Typeclass opts must be specified as an attrset of functions.
      Either clarify the deriving class by partial name (ie `MyClass.myOp = ...`)
      or by complete type signature (ie `$${typeSig MyClass}.myOp = ...`).
    '';
      decl.ops
      # XXX: WARNING: TODO: this code is unfinished!!!!
      # XXX: WARNING: TODO: this code is unfinished!!!!
      # XXX: WARNING: TODO: this code is unfinished!!!!
      # XXX: WARNING: TODO: this code is unfinished!!!!
      # XXX: WARNING: TODO: this code is unfinished!!!!
      # XXX: WARNING: TODO: this code is unfinished!!!!
      # XXX: WARNING: TODO: this code is unfinished!!!!
      # XXX: WARNING: TODO: this code is unfinished!!!!
      # XXX: WARNING: TODO: this code is unfinished!!!!
      # XXX: WARNING: TODO: this code is unfinished!!!!
      # XXX: WARNING: TODO: this code is unfinished!!!!
      # XXX: WARNING: TODO: this code is unfinished!!!!
      # XXX: WARNING: TODO: this code is unfinished!!!!
      # XXX: WARNING: TODO: this code is unfinished!!!!
      # XXX: WARNING: TODO: this code is unfinished!!!!
      # XXX: WARNING: TODO: this code is unfinished!!!!
      |> partition (x: true); # i forgor, TODO: rember :(

    # NOTE: reqDerived can/will contain duplicates
    # NOTE: it's wasteful to filter uniques now, just wait
    reqDerived =
      decl.derive
      |> map (x: x.req)
      |> mergeAttrsList;

    reqSelf =
      decl.ops
      |> filter isRequire;

    reqPaths =
      (reqDerived ++ reqSelf)
      |> unique # XXX: now we filter uniques
      |> 3;

    # reqPaths =
    #   decl.req
    #   |> mapAttrs (name: let
    #     segs = parseClassSig name;
    #   in
    #     value: segs ++ [value]);

    # XXX: TODO: having to specify the full namespace sucks :(

    matches = partition (flip hasAttrAt decl.ops) reqPaths;

    pathsMissing = matches.wrong;
    opsSelf = removeAttrsRec matches.right decl.ops;
    opsDerived = removeAttrsRec matches.wrong decl.ops;
  in {
    inherit opsSelf opsDerived pathsMissing;
    success = length pathsMissing == 0;
  };

  mkClass = sig: decl:
    assert enfIsClassSig sig "mkClass";
    assert decl.derive
    |> all (x:
      isClass x
      || throw ''
        NixTypes can only derive from NixType classes!
        However, ${sig} derives from invalid ${x} (type: ${typeOf x}).
      ''); let
      # XXX: TODO: enforce that every derive is a class!
      allDerivedClasses =
        decl.derive
        |> map (class: [typeSig class] ++ class.${ntTrapdoorKey}.derive)
        |> concatLists;

      parseResult = parseOps decl;
      inherit
        (parseResult)
        opsSelf
        opsDerived
        ;
    in
      # XXX: WARNING: classes currently *shouldn't* be able to inherit ops (i think?)
      assert parseResult.success || throw "TODO";
        mkTrapdoorSet {
          default = opsSelf;
          unlock = {
            # TODO: rename derive to deriveSigs (EXCEPT in the classDecl)
            ${ntTrapdoorKey} = {
              inherit sig;
              derive = allDerivedClasses;
              ops = opsDerived // {${sig} = opsSelf;};
              req = null;
            };
          };
        };

  mkType = sig: decl:
    assert enfIsTypeSig sig "mkType"; let
      allDerivedClasses =
        decl.derive
        |> map (class: typeSig class ++ class.${ntTrapdoorKey}.derive);

      parseResult = parseOps decl;
      inherit
        (parseResult)
        opsSelf
        opsDerived
        ;
    in
      # XXX: WARNING: classes currently *shouldn't* be able to inherit ops (i think?)
      assert parseResult.success || throw "TODO";
        opsSelf.mk;
in {
  Class = sig: builder:
    recdef (Self:
      unwrapBuilder builder Self
      |> parseDecl classDecl
      |> mkClass sig);

  Type = sig: builder:
    recdef (Self:
      unwrapBuilder builder Self
      |> parseDecl typeDecl
      |> mkType sig);
}
