# WARNING: /nt/primitives/bootstrap cannot depend on mix
# WARNING: this file is strictly for bootstrapping nt
{bootstrap, ...}: let
  # WARNING: do not propagate `this` from parent, bootstrap/std must
  # WARNING: remain entirely independent from bootstrap
  this = bootstrap {inherit this bootstrap;} [
    ./attrs.nix
    ./fn.nix
    ./list.nix
    ./num.nix
    ./string.nix
  ];
in
  this
