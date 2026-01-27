{this, ...}: let
  inherit
    (this)
    ntTrapdoorKey
    ntDynamicTrapdoorKey
    ;

  inherit
    (this.std)
    enfImpls
    ;

  inherit
    (this.trapdoor)
    mkTrapdoorFn
    mkTrapdoorSet
    openTrapdoor
    ;
in rec {
  unwrapMaybe = f: self:
    assert enfImpls "nt::&Maybe" self "nt::&Maybe.unwrap";
      (self |> openTrapdoor ntTrapdoorKey).ops."nt::&Maybe".unwrap f self;
  unwrapSome = f: self: f (self |> openTrapdoor ntDynamicTrapdoorKey).value;
  unwrapNone = f: self: null;

  # NOTE: Maybe is used to simplify parsing Type/Class declarations
  # NOTE: and therefore must be implemented manually
  Maybe = let
    meta = instance: {
      sig = "nt::&Maybe";
      derive = [];
      ops = {};
      req = {"nt::&Maybe" = ["unwrap"];};
    };
  in
    mkTrapdoorFn {
      default = {
        unwrap = unwrapMaybe;
      };
      unlock.${ntTrapdoorKey} = meta false;
    };

  Some = let
    meta = instance: {
      inherit instance;
      sig = "nt::Some";
      derive = ["nt::&Maybe"];
      ops = {
        "nt::&Maybe".unwrap = unwrapSome;
      };
      req = {};
    };
  in
    mkTrapdoorFn {
      default = value:
        mkTrapdoorSet {
          default = {};
          unlock = {
            ${ntTrapdoorKey} = meta true;
            ${ntDynamicTrapdoorKey} = {
              inherit value;
            };
          };
        };
      unlock.${ntTrapdoorKey} = meta false;
    };

  None = let
    meta = instance: {
      inherit instance;
      sig = "nt::None";
      derive = ["nt::&Maybe"];
      ops = {
        "nt::&Maybe".unwrap = unwrapNone;
      };
      req = {};
    };
  in
    mkTrapdoorFn {
      default = mkTrapdoorSet {
        default = {};
        unlock = {
          ${ntTrapdoorKey} = meta true;
        };
      };
      unlock.${ntTrapdoorKey} = meta false;
    };
}
