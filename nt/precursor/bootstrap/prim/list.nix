{...}: let
  inherit
    (builtins)
    elem
    elemAt
    foldl'
    genList
    length
    ;
in rec {
  # contains = x: list:
  #   list
  #   |> foldl' (state: el: state || el == x) false;
  contains = elem;

  sublist = start: count: list: let
    len = length list;
  in
    genList (n: elemAt list (n + start)) (
      if start >= len
      then 0
      else if start + count > len
      then len - start
      else count
    );

  take = count: sublist 0 count;

  init = list:
    assert (list != []) || throw "lists.init: list must not be empty!";
      take (length list - 1) list;

  last = list:
    assert (list != []) || throw "lists.last: list must not be empty!";
      elemAt list (length list - 1);

  # REF: pkgs.lib.lists.reverseList
  reverse = xs: let
    l = length xs;
  in
    genList (n: elemAt xs (l - n - 1)) l;

  # REF: pkgs.lib.lists.foldr
  foldr = op: nul: list: let
    len = length list;
    fold' = n:
      if n == len
      then nul
      else op (elemAt list n) (fold' (n + 1));
  in
    fold' 0;

  # REF: pkgs.lib.lists.findFirstIndex [MODIFIED]
  firstIndexWhere = pred: default: list: let
    resultIndex =
      foldl' (
        index: el:
          if index < 0
          then
            # No match yet before the current index, we need to check the element
            if pred el
            then
              # We have a match! Turn it into the actual index to prevent future iterations from modifying it
              -index - 1
            else
              # Still no match, update the index to the next element (we're counting down, so minus one)
              index - 1
          else
            # There's already a match, propagate the index without evaluating anything
            index
      ) (-1)
      list;
  in
    if resultIndex < 0
    then default
    else resultIndex;

  firstIndexOf = x: firstIndexWhere (el: el == x);

  # WARNING: returns `default` in the edgecase `pred el && el == null`
  firstWhere = pred: default: list: let
    index = firstIndexWhere pred null list;
  in
    if index == null
    then default
    else elemAt list index;

  unique = list:
    list
    |> foldl' (
      acc: el:
        if acc |> contains el
        then acc
        else acc ++ [el]
    ) [];
}
