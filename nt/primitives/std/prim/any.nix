{...}: let
  inherit
    (builtins)
    typeOf
    ;
in {
  enfIsPrimitive = type: value: msg: let
    got = typeOf value;
  in
    got == type || throw "${msg}: expected primitive nix type \"${type}\" but got \"${got}\"";
}
