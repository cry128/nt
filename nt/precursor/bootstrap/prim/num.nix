{...}: let
  inherit
    (builtins)
    elemAt
    genList
    length
    ;
in rec {
  inc = x: x + 1;
  dec = x: x - 1;

  countEvensLeq = n: n / 2;
  countOddsLeq = n: (n + 1) / 2;

  nats = genList (x: x);

  odds = genList (x: 2 * x + 1);
  oddsLeq = n: countOddsLeq n |> genList (x: 2 * x + 1);

  evens = genList (x: 2 * x);
  evensLeq = n: countEvensLeq n |> genList (x: 2 * x);

  # WARNING: mapOdd/mapEven assuming the indexing set begins even (ie start counting from 0)
  mapOdd = f: list: oddsLeq (length list - 1) |> map (i: f (elemAt list i));
  mapEven = f: list: evensLeq (length list + 1) |> map (i: f (elemAt list i));

  # WARNING: filterOdd/filterEven assuming the indexing set begins even (ie start counting from 0)
  filterOdd = mapOdd (x: x);
  filterEven = mapEven (x: x);
}
