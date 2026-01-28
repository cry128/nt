# WARNING: /nt/primitives/bootstrap cannot depend on mix
# WARNING: this file is strictly for bootstrapping nt
{bootstrap, ...}:
# WARNING: do not propagate `this` from parent, bootstrap/std must
# WARNING: remain entirely independent from bootstrap/
bootstrap {} [
  ./any.nix
  ./attrs.nix
  ./fn.nix
  ./list.nix
  ./num.nix
  ./string.nix
]
