{...}: let
  inherit
    (builtins)
    genList
    match
    replaceStrings
    stringLength
    substring
    ;
in rec {
  stringElem = i: substring i 1;
  stringTake = substring 0;
  stringHead = stringTake 1;
  stringTail = x: x |> substring 1 (stringLength x - 1);
  stringInit = x: x |> stringTake 1;
  stringLast = x: stringElem (stringLength x - 1);

  stringToCharacters = s: genList (p: substring p 1 s) (stringLength s);

  escape = list: replaceStrings list (map (c: "\\${c}") list);
  escapeRegex = escape (stringToCharacters "\\[{()^$?*+|.");

  hasInfix = infix: content:
    match ".*${escapeRegex infix}.*" "${content}" != null;

  removeSuffix = suffix: str: let
    sufLen = stringLength suffix;
    sLen = stringLength str;
  in
    if sufLen <= sLen && suffix == substring (sLen - sufLen) sufLen str
    then substring 0 (sLen - sufLen) str
    else str;

  prefix = prefix: str: "${prefix}${str}";
  suffix = suffix: str: "${str}${suffix}";
  surround = prefix: suffix: str: "${prefix}${str}${suffix}";
}
