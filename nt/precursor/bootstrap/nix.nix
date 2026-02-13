{...}: let
  inherit
    (builtins)
    pathExists
    ;
in {
  findImport = path: let
    pathA = path + "/default.nix";
    pathB = path + ".nix";
  in
    if pathExists pathA
    then pathA
    else if pathExists pathB
    then pathB
    else path;
}
