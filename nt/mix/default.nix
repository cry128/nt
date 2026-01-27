{this, ...}: let
  inherit
    (builtins)
    attrNames
    hasAttr
    isAttrs
    isFunction
    listToAttrs
    removeAttrs
    typeOf
    ;

  inherit
    (this)
    enfIsPrimitive
    ;

  inherit
    (this.std)
    filterAttrs
    hasInfix
    mergeAttrsList
    nameValuePair
    removeSuffix
    ;

  inherit
    (this.parse)
    projectOnto
    ;

  inherit
    (this.types)
    Wrap
    ;

  modNameFromPath = path: let
    name = baseNameOf path |> removeSuffix ".nix";
  in
    assert (! hasInfix "." name)
    || throw ''
      Mix module ${path} has invalid name \"${name}\".
      Module names must not contain the . (period) character.
    ''; name;
in rec {
  # by default the imported module is given the basename of its path
  # but you can set it manually by using the `mix.mod` function.

  importMod = path: inputs:
    assert enfIsPrimitive "path" path "importMod"; let
      mod = import path;
    in
      if isAttrs mod
      then mod
      else let
        modResult = mod inputs;
      in
        # TODO: create a better version of toString that can handle sets, lists, and null
        assert isFunction mod
        || throw ''
          Mix modules expect primitive type "set" or "lambda" (returning "set").
          Got primitive type "${typeOf mod}" instead.
        '';
        assert isAttrs modResult
        || throw ''
          Mix module provided as primitive type "lambda" must return primitive type "set"!
          Got primitive return type "${typeOf modResult} instead."
        ''; modResult;

  mkSubMods = list: inputs:
    list
    |> map (path: nameValuePair (modNameFromPath path) (importMod path inputs))
    |> listToAttrs;

  mkIncludes = list: inputs:
    list
    |> map (path: (importMod path inputs))
    |> mergeAttrsList;

  # create a new and empty mixture
  newMixture' = let
    self = {
      # trapdoor attribute
      _' = {
        path = [];
        modName = null;
      };
    };
  in
    self;

  # a splash of this, a splash of that ^_^
  add = ingredients: mixture: let
    sidedish = mergeAttrsList ingredients;
  in
    # bone apple tea ;-;
    mixture // filterAttrs (x: _: ! hasAttr x mixture) sidedish;

  newMixture = inputs: modBuilder: let
    inputs' = removeAttrs inputs ["this"];
    inputsWithThis = inputs' // {this = mixture;};

    # mixture components are ordered based on shadowing
    mixture =
      inputs'
      // mkSubMods meta.submods.public inputsWithThis
      // mkIncludes meta.includes.public inputsWithThis
      // content;

    # this = {
    #   # trapdoor attribute
    #   _' = {
    #     path = [];
    #   };
    #   parent' = throw "Mix: The mixture's root module has no parent by definition.";
    # };

    # partition modAttrs' into metadata and content
    modAttrs' = modBuilder mixture;
    content = removeAttrs modAttrs' (attrNames meta);
    # attributes expected by and that directly modify mix's behaviour
    meta =
      modAttrs'
      |> projectOnto
      {
        includes = {
          public = [];
          private = [];
          protected = [];
        };
        submods = {
          public = [];
          private = [];
          protected = [];
        };
        options = Wrap {};
        config = Wrap {};
      };
  in
    mixture;

  mkMod = mixture: modBuilder: let
    # XXX: TODO
    # modAttrs = modBuilder privateMixture;
    modAttrs = modBuilder mixture;

    # attributes expected by and that directly modify mix's behaviour
    meta =
      modAttrs
      |> projectOnto
      {
        includes = {
          public = [];
          private = [];
          protected = [];
        };
        submods = {
          public = [];
          private = [];
          protected = [];
        };
        options = Wrap {};
        config = Wrap {};
      };

    # XXX: TODO
    # protectedMixture = add [public protected] mixture;
    # privateMixture = add [private] protectedMixture;

    mkInterface = name: mixture: base:
      mergeAttrsList [
        base
        (mkIncludes meta.includes.${name} mixture)
        (mkSubMods meta.submods.${name} mixture)
      ];
    # XXX: TODO
    # NOTE: public submodules are still DESCENDENTS
    # NOTE: and should be able to access protected values :)
    # public = mkInterface "public" protectedMixture content;
    # protected = mkInterface "protected" protectedMixture public;
    # private = mkInterface "private" privateMixture protected;
    content = throw "TODO";
    public = mkInterface "public" mixture content;
    protected = mkInterface "protected" mixture public;
    private = mkInterface "private" mixture protected;
  in
    # XXX: TODO
    # public;
    modAttrs;
}
