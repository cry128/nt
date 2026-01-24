{this, ...}: let
  inherit
    (builtins)
    hasAttr
    typeOf
    ;

  inherit
    (this)
    isClassSig
    isNT
    isTypeSig
    ;
in rec {
  enfIsType = type: value: msg: let
    got = typeOf value;
  in
    got == type || throw "${msg}: expected primitive nix type \"${type}\" but got \"${got}\"";

  # NOTE: doesn't check if xs is type set, use enfHasAttr instead
  enfHasAttr' = name: xs: msg:
    hasAttr name xs || throw "${msg}: missing required attribute \"${name}\"";

  # NOTE: use enfHasAttr' if you can guarantee xs is type set
  enfHasAttr = name: xs: msg:
    enfIsType "set" xs msg && enfHasAttr' name xs msg;

  enfIsClassSig = sig: msg:
    isClassSig sig || throw "${msg}: given value \"${toString sig}\" of primitive nix type \"${typeOf sig}\" is not a valid Typeclass signature";

  enfIsTypeSig = sig: msg:
    isTypeSig sig || throw "${msg}: given value \"${toString sig}\" of primitive nix type \"${typeOf sig}\" is not a valid Type signature";

  enfIsNT = T: msg:
    isNT T || throw "${msg}: expected nt compatible type but got \"${toString T}\" of primitive nix type \"${typeOf T}\"";
}
