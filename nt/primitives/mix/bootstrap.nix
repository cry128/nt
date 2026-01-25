# WARNING: This file is strictly for bootstrapping nt
rec {
  # NOTE: bootstrap does the equivalent to mix's `include.public` option.
  # NOTE: It also provides itself as input to descendents.
  bootstrap = args: paths: let
    input = args // {inherit this bootstrap;};
    this = paths |> builtins.foldl' (acc: el: acc // import el input) {};
  in
    this;
}
