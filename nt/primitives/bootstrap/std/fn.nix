{...}: {
  id = x: x;
  flipCurry = f: a: b: f b a;

  # not sure where else to put this...
  nullOr = f: x:
    if x != null
    then f x
    else x;
}
