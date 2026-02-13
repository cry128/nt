{...}: let
  inherit
    (builtins)
    pathExists
    ;
in {
  findImport = path:
    if pathExists path
    then path
    else if pathExists (path + "default.nix")
    then path + "/default.nix"
    else path + ".nix";
}
