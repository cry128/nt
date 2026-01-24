{this, ...}: let
  inherit
    (builtins)
    isFunction
    length
    mapAttrs
    partition
    ;

  inherit
    (this.util)
    enfType
    enfIsClassSig
    flipCurry
    hasAttrAt
    mkTrapdoorSet
    ntTrapdoorKey
    parseClassSig
    projectOnto
    removeAttrsRec
    typeSig
    Wrap
    ;

  recdef = def: let
    Self = def Self;
  in
    Self;

  classDecl = {
    derive = Wrap [];
    ops = Wrap {};
  };

  unwrapBuilder = builder: Self:
    if isFunction builder
    then builder Self
    else builder;

  parseDecl = base: decl:
    assert enfType "set" decl "parseDecl";
    # ^^^^ "Type declaration must be provided as an attribute set, got "${typeOf decl}" instead!"
      decl |> projectOnto base;

  # Algorithm: given a full set of ops, iterate each op and
  # IF IT MATCHES A DERIVE BY FULL NAMESPACE
  # THEN remove it from state.req
  # ELSE IF IT IS SPECIFIED BY NAMESPACE
  # THEN add it to a list of all invalid ops (errors)
  # ELSE add it to a list of ops belonging solely to self
  parseOps = ops: req: let
    reqPaths =
      req
      |> mapAttrs (name: let
        segs = parseClassSig name;
      in
        value: segs ++ [value]);

    # XXX: TODO: having to specify the full namespace sucks :(

    matches = partition (flipCurry hasAttrAt ops) reqPaths;

    pathsMissing = matches.wrong;
    opsSelf = removeAttrsRec matches.right ops;
    opsDerived = removeAttrsRec matches.wrong ops;
  in {
    inherit opsSelf opsDerived pathsMissing;
    success = length pathsMissing == 0;
  };

  mkClass = sig: decl:
    assert enfIsClassSig sig "mkClass"; let
      allDerivedClasses =
        decl.derive
        |> map (class: typeSig class ++ class.${ntTrapdoorKey}.derive);

      parseResult = parseOps decl.ops decl.req;
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
              ops = {${sig} = opsSelf;} // opsDerived;
              req = null; # XXX: TODO make it more advanced
            };
          };
        };
in {
  Class = sig: builder:
    recdef (Self:
      unwrapBuilder builder Self
      |> parseDecl classDecl
      |> mkClass sig);
}
