{this, ...}: let
  inherit
    (builtins)
    typeOf
    ;

  inherit
    (this)
    impls
    isClassSig
    isNT
    isTypeSig
    toTypeSig
    ;
in {
  enfIsType = type: value: msg: let
    got = typeOf value;
  in
    got == type || throw "${msg}: expected primitive nix type \"${type}\" but got \"${got}\"";

  enfIsClassSig = sig: msg:
    isClassSig sig || throw "${msg}: given value \"${toString sig}\" of primitive nix type \"${typeOf sig}\" is not a valid Typeclass signature";

  enfIsTypeSig = sig: msg:
    isTypeSig sig || throw "${msg}: given value \"${toString sig}\" of primitive nix type \"${typeOf sig}\" is not a valid Type signature";

  enfIsNT = T: msg:
    isNT T || throw "${msg}: expected nt compatible type but got \"${toString T}\" of primitive nix type \"${typeOf T}\"";

  enfImpls = type: T: msg:
    impls type T || throw "${msg}: given type \"${toTypeSig T}\" does not implement typeclass \"${toTypeSig type}\"";
}
